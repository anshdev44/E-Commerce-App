// MongoDB Shell Commands to Insert Products
// Run this in MongoDB shell: mongosh
// Or use: mongosh < mongodb_products_insert.js

// Switch to your database (change if different)
use('e-commerce-app');

// Clear existing products (optional - remove if you want to keep existing)
// db.products.deleteMany({});

// Insert 10 Electronics Products
db.products.insertMany([
  {
    name: "Wireless Bluetooth Earbuds",
    description: "Premium wireless earbuds with active noise cancellation, 30-hour battery life, and crystal-clear sound quality. Perfect for music lovers and professionals.",
    price: 2999,
    category: "Electronics",
    in_stock: 50,
    image_url: "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Smart LED TV 55 inch",
    description: "Ultra HD 4K Smart TV with HDR10, built-in streaming apps, voice control, and sleek design. Transform your living room entertainment experience.",
    price: 45999,
    category: "Electronics",
    in_stock: 25,
    image_url: "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Laptop 15.6 inch",
    description: "High-performance laptop with Intel Core i7, 16GB RAM, 512GB SSD, and dedicated graphics. Ideal for work, gaming, and creative projects.",
    price: 69999,
    category: "Electronics",
    in_stock: 30,
    image_url: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Smartphone 128GB",
    description: "Latest flagship smartphone with 6.7-inch AMOLED display, triple camera system, 5G connectivity, and all-day battery life.",
    price: 34999,
    category: "Electronics",
    in_stock: 75,
    image_url: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Wireless Gaming Mouse",
    description: "Ergonomic gaming mouse with RGB lighting, 16000 DPI sensor, programmable buttons, and ultra-fast wireless connectivity for competitive gaming.",
    price: 2499,
    category: "Electronics",
    in_stock: 60,
    image_url: "https://images.unsplash.com/photo-1527814050087-3793815479db?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Portable Bluetooth Speaker",
    description: "Waterproof portable speaker with 360-degree sound, 20-hour battery, and built-in microphone for hands-free calls. Perfect for outdoor adventures.",
    price: 3999,
    category: "Electronics",
    in_stock: 40,
    image_url: "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Smart Watch Fitness Tracker",
    description: "Advanced fitness smartwatch with heart rate monitor, GPS, sleep tracking, and 50+ sports modes. Stay connected and healthy on the go.",
    price: 8999,
    category: "Electronics",
    in_stock: 55,
    image_url: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "USB-C Fast Charger",
    description: "65W fast charging adapter with USB-C and USB-A ports, compatible with laptops, phones, and tablets. Charge multiple devices simultaneously.",
    price: 1299,
    category: "Electronics",
    in_stock: 100,
    image_url: "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Mechanical Gaming Keyboard",
    description: "RGB mechanical keyboard with Cherry MX switches, customizable keys, and durable aluminum frame. Enhance your gaming and typing experience.",
    price: 5999,
    category: "Electronics",
    in_stock: 35,
    image_url: "https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Wireless Headphones Over-Ear",
    description: "Premium over-ear headphones with active noise cancellation, 40mm drivers, 30-hour battery, and comfortable memory foam ear cushions.",
    price: 7999,
    category: "Electronics",
    in_stock: 45,
    image_url: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

print("✅ Successfully inserted 10 Electronics products!");

// Verify the insertion
print("\n📊 Product Count: " + db.products.countDocuments({}));
print("📱 Electronics Count: " + db.products.countDocuments({category: "Electronics"}));





