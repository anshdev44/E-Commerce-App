from fastapi import FastAPI, HTTPException, Depends, Body
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from passlib.context import CryptContext
from jose import JWTError, jwt
from typing import Optional, List, Dict
from datetime import datetime, timedelta
from pymongo import MongoClient
import os
import razorpay
import hmac
import hashlib
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
DATABASE_NAME = os.getenv("DATABASE_NAME", "e-commerce-app")
COLLECTION_NAME = "users"

# Global MongoDB connection variables
client = None
db = None
users_collection = None
products_collection = None
cart_collection = None
wishlist_collection = None
orders_collection = None
selling_products_collection = None

def get_mongo_client():
    """Get or create MongoDB client with retry logic"""
    global client, db, users_collection, products_collection, cart_collection, wishlist_collection, orders_collection, selling_products_collection
    
    try:
        if client is None:
            print(f"Connecting to MongoDB at {MONGO_URL}...")
            client = MongoClient(
                MONGO_URL, 
                serverSelectionTimeoutMS=10000,
                connectTimeoutMS=10000,
                socketTimeoutMS=10000
            )
        
        # Test connection
        client.admin.command('ping')
        
        # Initialize database and collections
        if db is None:
            db = client[DATABASE_NAME]
            users_collection = db[COLLECTION_NAME]
            products_collection = db["products"]
            cart_collection = db["cart"]
            wishlist_collection = db["wishlist"]
            orders_collection = db["orders"]
            selling_products_collection = db["selling_products"]
        
        return client, db, users_collection, products_collection, cart_collection, wishlist_collection, orders_collection
    except Exception as e:
        print(f"MongoDB connection error: {e}")
        print(f"Connection string: {MONGO_URL}")
        print("Attempting to reconnect on next request...")
        # Reset connection to allow retry
        client = None
        db = None
        users_collection = None
        products_collection = None
        cart_collection = None
        wishlist_collection = None
        orders_collection = None
        selling_products_collection = None
        raise

# Try initial connection
try:
    get_mongo_client()
    print("MongoDB connection successful!")
except Exception as e:
    print(f"Initial MongoDB connection failed: {e}")
    print("Will attempt to connect when first request is made.")

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

class UserCreate(BaseModel):
    username: str
    email: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str


class Product(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    category: Optional[str] = None
    in_stock: int
    image_url: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class SellingProduct(BaseModel):
    """Model for user-listed products in the selling_products collection."""
    name: str
    description: str
    price: float
    quantity: int
    image_url: Optional[str] = None
    seller_email: str
    status: str = "unsold"  # unsold, sold
    category: Optional[str] = "User Listings"
    selling_type: str = "normal"  # normal, safe
    seller_pincode: Optional[str] = None  # Deprecated, kept for backward compatibility
    seller_pincodes: Optional[List[str]] = None  # Up to 10 pincodes for safe selling

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[float] = None
    category: Optional[str] = None
    in_stock: Optional[int] = None
    image_url: Optional[str] = None
    updated_at: Optional[datetime] = None

PRODUCTS_COLLECTION_NAME = "products"
SELLER_PRODUCT_PREFIX = "seller_"

def convert_product_to_dict(product_doc, source: str = "catalog"):
    """Convert MongoDB product document to a proper dictionary"""
    if product_doc is None:
        return None
    
    # MongoDB documents from PyMongo are already dict-like, but ensure proper conversion
    # Handle both dict and BSON document types
    if isinstance(product_doc, dict):
        product_dict = product_doc
    else:
        # Convert BSON document to dict
        try:
            product_dict = dict(product_doc)
        except (TypeError, AttributeError):
            # Fallback: try to access as dict
            product_dict = {k: getattr(product_doc, k, None) for k in dir(product_doc) if not k.startswith('_')}
    
    # Get image_url - try multiple possible field names and handle None
    image_url = (
        product_dict.get("image_url") or 
        product_dict.get("imageUrl") or 
        product_dict.get("image") or 
        ""
    )
    # Ensure it's a string, not None
    if image_url is None:
        image_url = ""
    
    # Build the result dictionary, ensuring all values are JSON-serializable
    product_id = str(product_dict.get("_id", ""))
    if source == "seller":
        product_id = f"{SELLER_PRODUCT_PREFIX}{product_id}"
        stock_value = int(product_dict.get("quantity", product_dict.get("in_stock", 0)))
    else:
        stock_value = int(product_dict.get("in_stock", product_dict.get("quantity", 0)))
    
    result = {
        "_id": product_id,
        "name": str(product_dict.get("name", "")),
        "description": str(product_dict.get("description", "")),
        "price": float(product_dict.get("price", 0.0)),
        "category": str(product_dict.get("category", "")),
        "in_stock": stock_value,
        "image_url": str(image_url),  # Explicitly convert to string
        "created_at": product_dict.get("created_at"),
        "updated_at": product_dict.get("updated_at"),
        "source": source,
        "seller_email": product_dict.get("seller_email"),
        "status": product_dict.get("status", "unsold" if source == "seller" else product_dict.get("status", "active")),
    }
    
    return result

def insert_sample_products():
    try:
        _, _, _, products_collection, _, _, _ = get_mongo_client()
        if products_collection.count_documents({}) == 0:
            sample_products = [
                {
                    "name": "Wireless Mouse",
                    "description": "A smooth and responsive wireless mouse.",
                    "price": 19.99,
                    "category": "Electronics",
                    "in_stock": 50,
                    "image_url": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
                {
                    "name": "Bluetooth Headphones",
                    "description": "Noise-cancelling over-ear headphones.",
                    "price": 59.99,
                    "category": "Electronics",
                    "in_stock": 30,
                    "image_url": "https://images.unsplash.com/photo-1511367461989-f85a21fda167?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
                {
                    "name": "Coffee Mug",
                    "description": "Ceramic mug for hot beverages.",
                    "price": 7.99,
                    "category": "Kitchen",
                    "in_stock": 100,
                    "image_url": "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
                {
                    "name": "Yoga Mat",
                    "description": "Non-slip yoga mat for all types of exercise.",
                    "price": 25.99,
                    "category": "Sports",
                    "in_stock": 40,
                    "image_url": "https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
                {
                    "name": "Classic Novel",
                    "description": "A timeless piece of literature.",
                    "price": 12.49,
                    "category": "Books",
                    "in_stock": 60,
                    "image_url": "https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
                {
                    "name": "T-shirt",
                    "description": "100% cotton unisex t-shirt.",
                    "price": 9.99,
                    "category": "Clothing",
                    "in_stock": 80,
                    "image_url": "https://images.unsplash.com/photo-1512436991641-6745cdb1723f?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
                {
                    "name": "Building Blocks Set",
                    "description": "Creative toy blocks for kids.",
                    "price": 29.99,
                    "category": "Toys",
                    "in_stock": 35,
                    "image_url": "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
                {
                    "name": "Face Moisturizer",
                    "description": "Hydrating daily face cream.",
                    "price": 15.99,
                    "category": "Beauty",
                    "in_stock": 70,
                    "image_url": "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?auto=format&fit=crop&w=400&q=80",
                    "created_at": datetime.utcnow(),
                    "updated_at": datetime.utcnow()
                },
            ]
            products_collection.insert_many(sample_products)
    except Exception as e:
        print(f"Could not insert sample products: {e}")

insert_sample_products()

class CartItem(BaseModel):
    product_id: str
    quantity: int

class Cart(BaseModel):
    user_email: str
    items: list[CartItem] = []

class Wishlist(BaseModel):
    user_email: str
    product_ids: list[str] = []

class ShippingAddress(BaseModel):
    full_name: str
    phone: str
    address_line1: str
    address_line2: Optional[str] = None
    city: str
    state: str
    postal_code: str
    country: str = "India"

class OrderItem(BaseModel):
    product_id: str
    product_name: str
    quantity: int
    price: float
    image_url: Optional[str] = None

class OrderCreate(BaseModel):
    user_email: str
    items: List[OrderItem]
    shipping_address: ShippingAddress
    total_amount: float
    payment_method: str = "razorpay"

class Order(BaseModel):
    order_id: str
    user_email: str
    items: List[OrderItem]
    shipping_address: ShippingAddress
    total_amount: float
    status: str  # pending, paid, processing, shipped, delivered, cancelled
    payment_id: Optional[str] = None
    razorpay_order_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime

# Razorpay Configuration
RAZORPAY_KEY_ID = os.getenv("RAZORPAY_KEY_ID", "")
RAZORPAY_KEY_SECRET = os.getenv("RAZORPAY_KEY_SECRET", "")

# Initialize Razorpay client
razorpay_client = None
if RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET:
    razorpay_client = razorpay.Client(auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET))
    print("Razorpay client initialized")
else:
    print("Warning: Razorpay keys not found. Payment features will not work.")

class DiscountStrategy:
    def apply(self, total: float) -> float:
        return total

class TenPercentOff(DiscountStrategy):
    def apply(self, total: float) -> float:
        return total * 0.9

class FlatDiscount(DiscountStrategy):
    def __init__(self, amount: float):
        self.amount = amount
    def apply(self, total: float) -> float:
        return max(0, total - self.amount)

def get_discount_strategy(discount_code: Optional[str]) -> Optional[DiscountStrategy]:
    """Factory function to get discount strategy based on discount code"""
    if not discount_code:
        return None
    
    discount_code = discount_code.upper()
    
    if discount_code == "10PERCENT" or discount_code == "TENOFF":
        return TenPercentOff()
    elif discount_code.startswith("FLAT"):
        # Extract amount from code like "FLAT50"
        try:
            amount = float(discount_code.replace("FLAT", ""))
            return FlatDiscount(amount)
        except ValueError:
            return None
    else:
        return None

@app.get("/cart", response_model=dict)
def get_cart(user_email: str):
    try:
        _, _, _, _, cart_collection, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    return {"items": items}

@app.post("/cart/add", response_model=dict)
def add_to_cart(user_email: str = Body(...), product_id: str = Body(...), quantity: int = Body(1)):
    try:
        _, _, _, _, cart_collection, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    found = False
    for item in items:
        if item["product_id"] == product_id:
            item["quantity"] += quantity
            found = True
            break
    if not found:
        items.append({"product_id": product_id, "quantity": quantity})
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": items}},
        upsert=True
    )
    return {"message": "Added to cart", "cart": items}

@app.put("/cart/update", response_model=dict)
def update_cart(user_email: str = Body(...), product_id: str = Body(...), quantity: int = Body(...)):
    try:
        _, _, _, _, cart_collection, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    for item in items:
        if item["product_id"] == product_id:
            if quantity > 0:
                item["quantity"] = quantity
            else:
                items.remove(item)
            break
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": items}},
        upsert=True
    )
    return {"message": "Cart updated", "cart": items}

@app.delete("/cart/remove", response_model=dict)
def remove_from_cart(user_email: str = Body(...), product_id: str = Body(...)):
    try:
        _, _, _, _, cart_collection, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    items = [item for item in items if item["product_id"] != product_id]
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": items}},
        upsert=True
    )
    return {"message": "Removed from cart", "cart": items}

@app.post("/cart/clear", response_model=dict)
def clear_cart(user_email: str = Body(...)):
    try:
        _, _, _, _, cart_collection, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    cart_collection.update_one(
        {"user_email": user_email},
        {"$set": {"items": []}},
        upsert=True
    )
    return {"message": "Cart cleared"}

@app.get("/cart/total", response_model=dict)
def cart_total(user_email: str, discount: str = None):
    try:
        _, _, _, products_collection, cart_collection, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    total = 0.0
    for item in items:
        product = products_collection.find_one({"_id": __import__('bson').ObjectId(item["product_id"])})
        if product:
            total += product['price'] * item['quantity']
    strategy = get_discount_strategy(discount) if discount else None
    if strategy:
        total = strategy.apply(total)
    return {"total": total}

@app.get("/cart/detailed", response_model=dict)
def get_cart_detailed(user_email: str):
    try:
        _, _, _, products_collection, cart_collection, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    cart = cart_collection.find_one({"user_email": user_email})
    items = cart["items"] if cart else []
    detailed_items = []
    from bson import ObjectId
    for item in items:
        try:
            prod = products_collection.find_one({"_id": ObjectId(item["product_id"])})
        except Exception:
            prod = None
        if prod:
            # Convert MongoDB document to proper dictionary with all fields
            product_dict = convert_product_to_dict(prod)
            detailed_items.append({"product": product_dict, "quantity": item["quantity"]})
    return {"items": detailed_items}

# --- Wishlist Endpoints ---
@app.get("/wishlist", response_model=dict)
def get_wishlist(user_email: str):
    try:
        _, _, _, _, _, wishlist_collection, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    return {"products": product_ids}

@app.post("/wishlist/add", response_model=dict)
def add_to_wishlist(user_email: str = Body(...), product_id: str = Body(...)):
    try:
        _, _, _, _, _, wishlist_collection, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    if product_id not in product_ids:
        product_ids.append(product_id)
    wishlist_collection.update_one(
        {"user_email": user_email},
        {"$set": {"product_ids": product_ids}},
        upsert=True
    )
    return {"message": "Added to wishlist", "wishlist": product_ids}

@app.delete("/wishlist/remove", response_model=dict)
def remove_from_wishlist(user_email: str = Body(...), product_id: str = Body(...)):
    try:
        _, _, _, _, _, wishlist_collection, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    product_ids = [pid for pid in product_ids if pid != product_id]
    wishlist_collection.update_one(
        {"user_email": user_email},
        {"$set": {"product_ids": product_ids}},
        upsert=True
    )
    return {"message": "Removed from wishlist", "wishlist": product_ids}

@app.post("/wishlist/clear", response_model=dict)
def clear_wishlist(user_email: str = Body(...)):
    try:
        _, _, _, _, _, wishlist_collection, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    wishlist_collection.update_one(
        {"user_email": user_email},
        {"$set": {"product_ids": []}},
        upsert=True
    )
    return {"message": "Wishlist cleared"}

@app.get("/wishlist/detailed", response_model=dict)
def get_wishlist_detailed(user_email: str):
    try:
        _, _, _, products_collection, _, wishlist_collection, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    wishlist = wishlist_collection.find_one({"user_email": user_email})
    product_ids = wishlist["product_ids"] if wishlist else []
    from bson import ObjectId
    products = []
    for pid in product_ids:
        try:
            prod = products_collection.find_one({"_id": ObjectId(pid)})
        except Exception:
            prod = None
        if prod:
            # Convert MongoDB document to proper dictionary with all fields
            product_dict = convert_product_to_dict(prod)
            products.append(product_dict)
    return {"products": products}


@app.get("/")
def read_root():
    return {"message": "FastAPI Backend with MongoDB is running!"}

@app.get("/health")
def health_check():
    try:
        client, _, _, _, _, _, _ = get_mongo_client()
        client.admin.command('ping')
        return {"status": "healthy", "database": "MongoDB connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": "MongoDB disconnected", "error": str(e)}

@app.get("/debug/products")
def debug_products():
    """Debug endpoint to see raw product data"""
    try:
        _, _, _, products_collection, _, _, _ = get_mongo_client()
        products = list(products_collection.find().limit(2))
        result = []
        for p in products:
            # Get raw document
            raw_doc = dict(p) if hasattr(p, '__dict__') else p
            # Get converted version
            converted = convert_product_to_dict(p)
            result.append({
                "raw": {k: str(v) for k, v in raw_doc.items()},
                "converted": converted
            })
        return {"debug": result, "count": len(products)}
    except Exception as e:
        return {"error": str(e)}

@app.post("/products/fix-images")
def fix_broken_image_urls():
    """Fix broken image URLs (source.unsplash.com) to use working placeholder images"""
    try:
        _, _, _, products_collection, _, _, _ = get_mongo_client()
        
        # Find all products with broken source.unsplash.com URLs
        broken_products = list(products_collection.find({
            "image_url": {"$regex": "source\\.unsplash\\.com", "$options": "i"}
        }))
        
        # Mapping of product categories to working placeholder images
        # Using picsum.photos which is reliable and provides random images
        category_images = {
            "Electronics": "https://picsum.photos/seed/electronics/400/400",
            "Toys": "https://picsum.photos/seed/toys/400/400",
            "Clothing": "https://picsum.photos/seed/clothing/400/400",
            "Books": "https://picsum.photos/seed/books/400/400",
            "Sports": "https://picsum.photos/seed/sports/400/400",
            "Beauty": "https://picsum.photos/seed/beauty/400/400",
            "Kitchen": "https://picsum.photos/seed/kitchen/400/400",
        }
        
        updated_count = 0
        for product in broken_products:
            category = product.get("category", "")
            # Use category-specific image or default placeholder
            new_image_url = category_images.get(category, "https://picsum.photos/400/400")
            
            products_collection.update_one(
                {"_id": product["_id"]},
                {"$set": {"image_url": new_image_url}}
            )
            updated_count += 1
        
        return {
            "message": f"Updated {updated_count} products with broken image URLs",
            "updated_count": updated_count,
            "total_broken": len(broken_products)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fixing images: {str(e)}")

@app.post("/signup", response_model=Token)
def signup(user: UserCreate):
    try:
        _, _, users_collection, _, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    existing_user = users_collection.find_one({"email": user.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    
    user_doc = {
        "username": user.username,
        "email": user.email,
        "hashed_password": get_password_hash(user.password),
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
   
    result = users_collection.insert_one(user_doc)
    
    if result.inserted_id:
        access_token = create_access_token(data={"sub": user.email})
        return {"access_token": access_token, "token_type": "bearer"}
    else:
        raise HTTPException(status_code=500, detail="Failed to create user")

@app.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    try:
        _, _, users_collection, _, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    user = users_collection.find_one({"email": form_data.username})
    
    if not user or not verify_password(form_data.password, user["hashed_password"]):
        raise HTTPException(status_code=400, detail="Incorrect email or password")
    
    access_token = create_access_token(data={"sub": user["email"]})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users")
def get_users():
    try:
        _, _, users_collection, _, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    users = list(users_collection.find({}, {"hashed_password": 0})) 
    return {"users": users, "count": len(users)}

@app.get("/users/profile")
def get_user_profile(email: str):
    """Get user profile by email"""
    try:
        _, _, users_collection, _, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    user = users_collection.find_one({"email": email}, {"hashed_password": 0})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Convert ObjectId to string
    user["_id"] = str(user["_id"])
    return user

@app.put("/users/profile")
def update_user_profile(email: str, profile_data: dict = Body(...)):
    """Update user profile"""
    try:
        _, _, users_collection, _, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    user = users_collection.find_one({"email": email})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Prepare update data (exclude email and password from updates)
    update_data = {}
    allowed_fields = ["username", "full_name", "phone_number", "address", "profile_photo_url"]
    
    for field in allowed_fields:
        if field in profile_data:
            update_data[field] = profile_data[field]
    
    if not update_data:
        raise HTTPException(status_code=400, detail="No valid fields to update")
    
    # Add updated_at timestamp
    update_data["updated_at"] = datetime.utcnow()
    
    result = users_collection.update_one(
        {"email": email},
        {"$set": update_data}
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=400, detail="No changes made")
    
    # Return updated user
    updated_user = users_collection.find_one({"email": email}, {"hashed_password": 0})
    updated_user["_id"] = str(updated_user["_id"])
    return {"message": "Profile updated successfully", "user": updated_user}

@app.post("/products", response_model=dict)
def create_product(product: Product):
    try:
        client, db, users_collection, products_collection, cart_collection, wishlist_collection, orders_collection = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    now = datetime.utcnow()
    product_dict = product.dict()
    product_dict["created_at"] = now
    product_dict["updated_at"] = now
    result = products_collection.insert_one(product_dict)
    if result.inserted_id:
        product_dict["_id"] = str(result.inserted_id)
        return {"product": product_dict}
    else:
        raise HTTPException(status_code=500, detail="Failed to create product")

@app.get("/products", response_model=dict)
def list_products(skip: int = 0, limit: int = 20):
    try:
        client, db, users_collection, products_collection, cart_collection, wishlist_collection, orders_collection = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    products = list(products_collection.find().skip(skip).limit(limit))
    # Convert MongoDB documents to proper dictionaries with all fields
    products_list = [convert_product_to_dict(p) for p in products]

    # Also include user-listed selling products that are still available
    try:
        selling_products_collection = db["selling_products"]
        selling_products = list(
            selling_products_collection.find(
                {
                    "quantity": {"$gt": 0},
                    "status": {"$ne": "sold"},
                }
            )
        )
        for sp in selling_products:
            products_list.append(
                {
                    "_id": str(sp.get("_id")),
                    "name": sp.get("name", ""),
                    "description": sp.get("description", ""),
                    "price": float(sp.get("price", 0)),
                    "category": sp.get("category", "User Listings"),
                    "in_stock": int(sp.get("quantity", 0)),
                    "image_url": sp.get("image_url", ""),
                    "seller_email": sp.get("seller_email", ""),
                    "is_user_listing": True,
                    "source": "selling_products",
                }
            )
    except Exception as e:
        # Don't break main products listing if selling products fail
        print(f"Error including selling products: {e}")

    return {"products": products_list, "count": len(products_list)}


@app.post("/selling-products", response_model=dict)
def create_selling_product(product: SellingProduct):
    """Create a new user-listed product in the selling_products collection."""
    try:
        client, db, users_collection, products_collection, cart_collection, wishlist_collection, orders_collection = get_mongo_client()
        selling_products_collection = db["selling_products"]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")

    now = datetime.utcnow()
    product_dict = product.dict()
    product_dict["status"] = product_dict.get("status", "unsold")

    # Basic validation for safe selling
    selling_type = product_dict.get("selling_type", "normal")

    def _normalize_pincodes(raw_pincodes, fallback_single):
        pins: List[str] = []

        if isinstance(raw_pincodes, list):
            pins = [str(pin).strip() for pin in raw_pincodes if str(pin).strip()]
        elif isinstance(raw_pincodes, str) and raw_pincodes.strip():
            # Comma or whitespace separated string
            pins = [p.strip() for p in raw_pincodes.replace(" ", ",").split(",") if p.strip()]

        if not pins and fallback_single:
            single = str(fallback_single).strip()
            if single:
                pins = [single]

        # Remove duplicates while preserving order
        seen = set()
        unique_pins = []
        for pin in pins:
            if pin not in seen:
                seen.add(pin)
                unique_pins.append(pin)
        return unique_pins

    normalized_pincodes = _normalize_pincodes(
        product_dict.get("seller_pincodes"),
        product_dict.get("seller_pincode"),
    )

    if selling_type == "safe":
        if not normalized_pincodes:
            raise HTTPException(
                status_code=400,
                detail="At least one seller pincode is required for safe selling",
            )
        if len(normalized_pincodes) > 10:
            raise HTTPException(
                status_code=400,
                detail="You can specify up to 10 pincodes for safe selling",
            )
    else:
        # Non-safe listings should not store pincodes
        normalized_pincodes = []

    product_dict["seller_pincodes"] = normalized_pincodes
    product_dict["seller_pincode"] = normalized_pincodes[0] if normalized_pincodes else None

    product_dict["created_at"] = now
    product_dict["updated_at"] = now
    result = selling_products_collection.insert_one(product_dict)
    if result.inserted_id:
        product_dict["_id"] = str(result.inserted_id)
        return {"product": product_dict}
    else:
        raise HTTPException(status_code=500, detail="Failed to create selling product")

@app.get("/products/search", response_model=dict)
def search_products(
    name: Optional[str] = None,
    category: Optional[str] = None,
    min_price: Optional[float] = None,
    max_price: Optional[float] = None,
    skip: int = 0,
    limit: int = 20
):
    try:
        _, _, _, products_collection, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    query = {}
    if name:
        query["name"] = {"$regex": name, "$options": "i"}
    if category:
        query["category"] = category
    if min_price is not None or max_price is not None:
        price_query = {}
        if min_price is not None:
            price_query["$gte"] = min_price
        if max_price is not None:
            price_query["$lte"] = max_price
        query["price"] = price_query
    products = list(products_collection.find(query).skip(skip).limit(limit))
    # Convert MongoDB documents to proper dictionaries with all fields
    products_list = [convert_product_to_dict(p) for p in products]
    return {"products": products_list, "count": len(products_list)}

@app.get("/products/{product_id}", response_model=dict)
def get_product(product_id: str):
    try:
        _, _, _, products_collection, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    from bson import ObjectId
    product = products_collection.find_one({"_id": ObjectId(product_id)})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    # Convert MongoDB document to proper dictionary with all fields
    product_dict = convert_product_to_dict(product)
    return {"product": product_dict}

@app.put("/products/{product_id}", response_model=dict)
def update_product(product_id: str, product: ProductUpdate):
    try:
        _, _, _, products_collection, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    from bson import ObjectId
    update_data = {k: v for k, v in product.dict().items() if v is not None}
    update_data["updated_at"] = datetime.utcnow()
    result = products_collection.update_one({"_id": ObjectId(product_id)}, {"$set": update_data})
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    updated_product = products_collection.find_one({"_id": ObjectId(product_id)})
    # Convert MongoDB document to proper dictionary with all fields
    product_dict = convert_product_to_dict(updated_product)
    return {"product": product_dict}

@app.delete("/products/{product_id}", response_model=dict)
def delete_product(product_id: str):
    try:
        _, _, _, products_collection, _, _, _ = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    from bson import ObjectId
    result = products_collection.delete_one({"_id": ObjectId(product_id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Product not found")
    return {"message": "Product deleted"}

# ========== ORDER & PAYMENT ENDPOINTS ==========

@app.post("/orders/create-razorpay-order")
def create_razorpay_order(order_data: dict = Body(...)):
    """Create a Razorpay order for payment"""
    # If Razorpay is not configured, simulate order creation for demo
    if razorpay_client is None:
        amount = int(order_data.get("amount", 0) * 100)  # Convert to paise
        currency = order_data.get("currency", "INR")
        receipt = order_data.get("receipt", f"order_{datetime.utcnow().timestamp()}")
        
        # Generate a demo order ID
        demo_order_id = f"order_demo_{datetime.utcnow().strftime('%Y%m%d%H%M%S')}{os.urandom(4).hex()}"
        
        return {
            "order_id": demo_order_id,
            "amount": amount,
            "currency": currency,
            "key_id": "demo_key_id"
        }
    
    try:
        amount = int(order_data.get("amount", 0) * 100)  # Convert to paise
        currency = order_data.get("currency", "INR")
        receipt = order_data.get("receipt", f"order_{datetime.utcnow().timestamp()}")
        
        razorpay_order = razorpay_client.order.create({
            "amount": amount,
            "currency": currency,
            "receipt": receipt,
            "notes": {
                "user_email": order_data.get("user_email", ""),
                "order_type": "buy_now"
            }
        })
        
        return {
            "order_id": razorpay_order["id"],
            "amount": razorpay_order["amount"],
            "currency": razorpay_order["currency"],
            "key_id": RAZORPAY_KEY_ID
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create Razorpay order: {str(e)}")

@app.post("/orders/create")
def create_order(order: OrderCreate):
    """Create an order in the database"""
    try:
        client, db, users_collection, products_collection, cart_collection, wishlist_collection, orders_collection = get_mongo_client()
        selling_products_collection = db["selling_products"]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    from bson import ObjectId

    shipping_pincode = (order.shipping_address.postal_code or "").strip()

    # Validate products and check stock (supports both catalog and user-listed products,
    # and apply safe-selling pincode rules when needed)
    validated_items = []
    for item in order.items:
        product = products_collection.find_one({"_id": ObjectId(item.product_id)})
        source = "products"
        stock_field = "in_stock"

        if not product:
            product = selling_products_collection.find_one({"_id": ObjectId(item.product_id)})
            source = "selling_products"
            stock_field = "quantity"

        if not product:
            raise HTTPException(status_code=404, detail=f"Product {item.product_id} not found")

        available = int(product.get(stock_field, 0))
        if available < item.quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient stock for {item.product_name}")

        # Safe selling rule: if this is a safe-selling listing, the buyer's pincode must match
        if source == "selling_products":
            selling_type = product.get("selling_type", "normal")

            raw_pincodes = product.get("seller_pincodes")
            if not raw_pincodes:
                single_pin = str(product.get("seller_pincode", "") or "").strip()
                raw_pincodes = [single_pin] if single_pin else []

            seller_pincodes = [str(pin).strip() for pin in raw_pincodes if str(pin).strip()]

            if selling_type == "safe" and seller_pincodes:
                if not shipping_pincode or shipping_pincode not in seller_pincodes:
                    allowed = ", ".join(seller_pincodes)
                    raise HTTPException(
                        status_code=400,
                        detail=(
                            "This item can only be sold in the following pincodes: "
                            f"{allowed}. Your shipping pincode is {shipping_pincode or 'not set'}."
                        ),
                    )

        validated_items.append(
            {
                "item": item,
                "product": product,
                "source": source,
                "stock_field": stock_field,
                "available": available,
            }
        )
    
    # Generate order ID
    order_id = f"ORD{datetime.utcnow().strftime('%Y%m%d%H%M%S')}{os.urandom(4).hex().upper()}"
    now = datetime.utcnow()
    
    # Create order document
    order_doc = {
        "order_id": order_id,
        "user_email": order.user_email,
        "items": [item.dict() for item in order.items],
        "shipping_address": order.shipping_address.dict(),
        "total_amount": order.total_amount,
        "status": "pending",
        "payment_id": None,
        "razorpay_order_id": None,
        "created_at": now,
        "updated_at": now
    }
    
    result = orders_collection.insert_one(order_doc)
    if not result.inserted_id:
        raise HTTPException(status_code=500, detail="Failed to create order")

    # Update stock for each item after successful order creation
    for entry in validated_items:
        item = entry["item"]
        product = entry["product"]
        source = entry["source"]
        stock_field = entry["stock_field"]
        available = entry["available"]

        new_quantity = max(available - item.quantity, 0)

        if source == "products":
            products_collection.update_one(
                {"_id": product["_id"]},
                {"$set": {stock_field: new_quantity, "updated_at": datetime.utcnow()}},
            )
        else:
            status = "unsold"
            if new_quantity <= 0:
                status = "sold"

            selling_products_collection.update_one(
                {"_id": product["_id"]},
                {
                    "$set": {
                        stock_field: new_quantity,
                        "status": status,
                        "updated_at": datetime.utcnow(),
                    }
                },
            )

    order_doc["_id"] = str(result.inserted_id)
    return {"order": order_doc, "message": "Order created successfully"}

@app.post("/orders/verify-payment")
def verify_payment(payment_data: dict = Body(...)):
    """Verify Razorpay payment and update order status"""
    try:
        _, _, _, products_collection, _, _, orders_collection = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    razorpay_order_id = payment_data.get("razorpay_order_id")
    razorpay_payment_id = payment_data.get("razorpay_payment_id")
    razorpay_signature = payment_data.get("razorpay_signature")
    order_id = payment_data.get("order_id")
    
    if not all([razorpay_order_id, razorpay_payment_id, razorpay_signature, order_id]):
        raise HTTPException(status_code=400, detail="Missing payment verification data")
    
    # Demo mode: Skip Razorpay verification if not configured
    if razorpay_client is None:
        # In demo mode, just verify the order exists and update it
        order = orders_collection.find_one({"order_id": order_id})
        if not order:
            raise HTTPException(status_code=404, detail="Order not found")
        
        # Update stock
        from bson import ObjectId
        for item in order["items"]:
            product = products_collection.find_one({"_id": ObjectId(item["product_id"])})
            if product:
                new_stock = product.get("in_stock", 0) - item["quantity"]
                products_collection.update_one(
                    {"_id": ObjectId(item["product_id"])},
                    {"$set": {"in_stock": max(0, new_stock), "updated_at": datetime.utcnow()}}
                )
        
        # Update order status
        orders_collection.update_one(
            {"order_id": order_id},
            {
                "$set": {
                    "status": "paid",
                    "payment_id": razorpay_payment_id,
                    "razorpay_order_id": razorpay_order_id,
                    "updated_at": datetime.utcnow()
                }
            }
        )
        
        updated_order = orders_collection.find_one({"order_id": order_id})
        updated_order["_id"] = str(updated_order["_id"])
        
        return {
            "success": True,
            "message": "Payment verified and order confirmed (demo mode)",
            "order": updated_order
        }
    
    # Production mode: Full Razorpay verification
    # Verify signature
    message = f"{razorpay_order_id}|{razorpay_payment_id}"
    generated_signature = hmac.new(
        RAZORPAY_KEY_SECRET.encode(),
        message.encode(),
        hashlib.sha256
    ).hexdigest()
    
    if not hmac.compare_digest(generated_signature, razorpay_signature):
        raise HTTPException(status_code=400, detail="Invalid payment signature")
    
    # Verify payment with Razorpay
    try:
        payment = razorpay_client.payment.fetch(razorpay_payment_id)
        if payment["status"] != "authorized" and payment["status"] != "captured":
            raise HTTPException(status_code=400, detail=f"Payment not successful. Status: {payment['status']}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Payment verification failed: {str(e)}")
    
    # Update order in database
    order = orders_collection.find_one({"order_id": order_id})
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    # Update stock
    from bson import ObjectId
    for item in order["items"]:
        product = products_collection.find_one({"_id": ObjectId(item["product_id"])})
        if product:
            new_stock = product.get("in_stock", 0) - item["quantity"]
            products_collection.update_one(
                {"_id": ObjectId(item["product_id"])},
                {"$set": {"in_stock": max(0, new_stock), "updated_at": datetime.utcnow()}}
            )
    
    # Update order status
    orders_collection.update_one(
        {"order_id": order_id},
        {
            "$set": {
                "status": "paid",
                "payment_id": razorpay_payment_id,
                "razorpay_order_id": razorpay_order_id,
                "updated_at": datetime.utcnow()
            }
        }
    )
    
    updated_order = orders_collection.find_one({"order_id": order_id})
    updated_order["_id"] = str(updated_order["_id"])
    
    return {
        "success": True,
        "message": "Payment verified and order confirmed",
        "order": updated_order
    }

@app.get("/orders")
def get_orders(user_email: str):
    """Get all orders for a user"""
    try:
        _, _, _, _, _, _, orders_collection = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    orders = list(orders_collection.find({"user_email": user_email}).sort("created_at", -1))
    
    # Convert to list of dicts
    orders_list = []
    for order in orders:
        order_dict = dict(order)
        order_dict["_id"] = str(order_dict["_id"])
        orders_list.append(order_dict)
    
    return {"orders": orders_list, "count": len(orders_list)}

@app.get("/orders/{order_id}")
def get_order(order_id: str):
    """Get a specific order by ID"""
    try:
        _, _, _, _, _, _, orders_collection = get_mongo_client()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
    
    order = orders_collection.find_one({"order_id": order_id})
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    order_dict = dict(order)
    order_dict["_id"] = str(order_dict["_id"])
    return {"order": order_dict}

if __name__ == "__main__":
    import uvicorn
    print("Starting FastAPI server with MongoDB...")
    print("Server will be accessible at:")
    print("  - http://localhost:8000 (local)")
    print("  - http://192.168.1.15:8000 (network)")
    uvicorn.run(app, host="0.0.0.0", port=8000)  # 0.0.0.0 allows connections from all network interfaces
