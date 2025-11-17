// MongoDB Shell Commands to Insert Products for All Categories
// Run this in MongoDB shell: mongosh
// Or use: mongosh < mongodb_all_categories_insert.js

// Switch to your database (change if different)
use('e-commerce-app');

// ========== ELECTRONICS (10 products) ==========
db.products.insertMany([
  {
    name: "Wireless Bluetooth Earbuds",
    description: "Premium wireless earbuds with active noise cancellation, 30-hour battery life, and crystal-clear sound quality.",
    price: 2999,
    category: "Electronics",
    in_stock: 50,
    image_url: "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Smart LED TV 55 inch",
    description: "Ultra HD 4K Smart TV with HDR10, built-in streaming apps, voice control, and sleek design.",
    price: 45999,
    category: "Electronics",
    in_stock: 25,
    image_url: "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Laptop 15.6 inch",
    description: "High-performance laptop with Intel Core i7, 16GB RAM, 512GB SSD, and dedicated graphics.",
    price: 69999,
    category: "Electronics",
    in_stock: 30,
    image_url: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Smartphone 128GB",
    description: "Latest flagship smartphone with 6.7-inch AMOLED display, triple camera system, and 5G connectivity.",
    price: 34999,
    category: "Electronics",
    in_stock: 75,
    image_url: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Wireless Gaming Mouse",
    description: "Ergonomic gaming mouse with RGB lighting, 16000 DPI sensor, and programmable buttons.",
    price: 2499,
    category: "Electronics",
    in_stock: 60,
    image_url: "https://images.unsplash.com/photo-1527814050087-3793815479db?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Portable Bluetooth Speaker",
    description: "Waterproof portable speaker with 360-degree sound, 20-hour battery, and built-in microphone.",
    price: 3999,
    category: "Electronics",
    in_stock: 40,
    image_url: "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Smart Watch Fitness Tracker",
    description: "Advanced fitness smartwatch with heart rate monitor, GPS, sleep tracking, and 50+ sports modes.",
    price: 8999,
    category: "Electronics",
    in_stock: 55,
    image_url: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "USB-C Fast Charger",
    description: "65W fast charging adapter with USB-C and USB-A ports, compatible with laptops, phones, and tablets.",
    price: 1299,
    category: "Electronics",
    in_stock: 100,
    image_url: "https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Mechanical Gaming Keyboard",
    description: "RGB mechanical keyboard with Cherry MX switches, customizable keys, and durable aluminum frame.",
    price: 5999,
    category: "Electronics",
    in_stock: 35,
    image_url: "https://images.unsplash.com/photo-1541140532154-b024d705b90a?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Wireless Headphones Over-Ear",
    description: "Premium over-ear headphones with active noise cancellation, 40mm drivers, and 30-hour battery.",
    price: 7999,
    category: "Electronics",
    in_stock: 45,
    image_url: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

// ========== CLOTHING (10 products) ==========
db.products.insertMany([
  {
    name: "Classic Cotton T-Shirt",
    description: "100% premium cotton t-shirt, comfortable fit, available in multiple colors. Perfect for everyday wear.",
    price: 599,
    category: "Clothing",
    in_stock: 150,
    image_url: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Men's Denim Jeans",
    description: "Classic fit denim jeans with stretch fabric, durable construction, and modern styling. Perfect for casual occasions.",
    price: 1999,
    category: "Clothing",
    in_stock: 80,
    image_url: "https://images.unsplash.com/photo-1542272604-787c3835535d?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Women's Summer Dress",
    description: "Elegant floral summer dress with breathable fabric, flattering silhouette, and vibrant colors. Ideal for parties and outings.",
    price: 2499,
    category: "Clothing",
    in_stock: 60,
    image_url: "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Sports Running Shoes",
    description: "Lightweight running shoes with cushioned sole, breathable mesh upper, and excellent grip for all terrains.",
    price: 3999,
    category: "Clothing",
    in_stock: 90,
    image_url: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Hooded Sweatshirt",
    description: "Comfortable hooded sweatshirt with soft fleece lining, adjustable drawstring, and spacious front pocket.",
    price: 1799,
    category: "Clothing",
    in_stock: 70,
    image_url: "https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Formal Business Shirt",
    description: "Crisp formal shirt with wrinkle-free fabric, classic collar, and perfect fit for professional settings.",
    price: 1299,
    category: "Clothing",
    in_stock: 100,
    image_url: "https://images.unsplash.com/photo-1594938291221-94f18c4552eb?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Winter Jacket",
    description: "Warm winter jacket with water-resistant outer shell, insulated lining, and multiple pockets for essentials.",
    price: 4999,
    category: "Clothing",
    in_stock: 50,
    image_url: "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Casual Shorts",
    description: "Comfortable casual shorts with elastic waistband, breathable fabric, and perfect for summer activities.",
    price: 899,
    category: "Clothing",
    in_stock: 120,
    image_url: "https://images.unsplash.com/photo-1506629905607-0c2c5c0c0c0c?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Leather Belt",
    description: "Genuine leather belt with classic buckle, adjustable sizing, and timeless design for formal and casual wear.",
    price: 799,
    category: "Clothing",
    in_stock: 85,
    image_url: "https://images.unsplash.com/photo-1624222247344-550fb60583fd?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Sunglasses Aviator",
    description: "Stylish aviator sunglasses with UV protection, polarized lenses, and lightweight metal frame.",
    price: 1499,
    category: "Clothing",
    in_stock: 65,
    image_url: "https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

// ========== GROCERIES (10 products) ==========
db.products.insertMany([
  {
    name: "Organic Honey 500g",
    description: "Pure organic honey sourced from natural beehives, rich in antioxidants and natural sweetness.",
    price: 399,
    category: "Groceries",
    in_stock: 200,
    image_url: "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Fresh Apples 1kg",
    description: "Crisp and juicy red apples, rich in fiber and vitamins. Perfect for healthy snacking.",
    price: 149,
    category: "Groceries",
    in_stock: 300,
    image_url: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Extra Virgin Olive Oil",
    description: "Premium cold-pressed olive oil, perfect for cooking and salad dressings. Rich in healthy fats.",
    price: 599,
    category: "Groceries",
    in_stock: 150,
    image_url: "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Basmati Rice 5kg",
    description: "Premium long-grain basmati rice, aromatic and fluffy when cooked. Perfect for biryanis and pulao.",
    price: 449,
    category: "Groceries",
    in_stock: 180,
    image_url: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Fresh Milk 1 Liter",
    description: "Fresh pasteurized milk, rich in calcium and protein. Daily essential for healthy nutrition.",
    price: 65,
    category: "Groceries",
    in_stock: 500,
    image_url: "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Whole Wheat Bread",
    description: "Fresh whole wheat bread, high in fiber and nutrients. Great for breakfast and sandwiches.",
    price: 45,
    category: "Groceries",
    in_stock: 400,
    image_url: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Organic Green Tea",
    description: "Premium organic green tea leaves, rich in antioxidants. Promotes metabolism and overall wellness.",
    price: 299,
    category: "Groceries",
    in_stock: 250,
    image_url: "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Fresh Tomatoes 1kg",
    description: "Ripe and fresh tomatoes, perfect for salads, cooking, and sauces. Rich in lycopene and vitamins.",
    price: 79,
    category: "Groceries",
    in_stock: 350,
    image_url: "https://images.unsplash.com/photo-1546095665306-9b0c4d1a3c1e?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Almonds 500g",
    description: "Premium quality almonds, rich in protein and healthy fats. Great for snacking and cooking.",
    price: 699,
    category: "Groceries",
    in_stock: 120,
    image_url: "https://images.unsplash.com/photo-1606312619070-d48b4bc6fe65?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Dark Chocolate Bar",
    description: "Rich dark chocolate with 70% cocoa, smooth texture, and indulgent taste. Perfect for dessert lovers.",
    price: 199,
    category: "Groceries",
    in_stock: 280,
    image_url: "https://images.unsplash.com/photo-1606312619070-d48b4bc6fe65?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

// ========== BOOKS (10 products) ==========
db.products.insertMany([
  {
    name: "The Complete Guide to Programming",
    description: "Comprehensive programming guide covering multiple languages, best practices, and real-world projects.",
    price: 1299,
    category: "Books",
    in_stock: 40,
    image_url: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Business Strategy Mastery",
    description: "Learn advanced business strategies, leadership skills, and entrepreneurial mindset from industry experts.",
    price: 899,
    category: "Books",
    in_stock: 35,
    image_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Fiction Novel - Mystery Thriller",
    description: "Gripping mystery thriller with unexpected twists, compelling characters, and a page-turning plot.",
    price: 499,
    category: "Books",
    in_stock: 60,
    image_url: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Cookbook - Healthy Recipes",
    description: "Collection of 200+ healthy and delicious recipes with nutritional information and cooking tips.",
    price: 699,
    category: "Books",
    in_stock: 45,
    image_url: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "History of Ancient Civilizations",
    description: "Fascinating journey through ancient civilizations, their cultures, achievements, and legacies.",
    price: 799,
    category: "Books",
    in_stock: 30,
    image_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Self-Help: Personal Development",
    description: "Transform your life with practical self-help strategies, mindfulness techniques, and goal-setting methods.",
    price: 599,
    category: "Books",
    in_stock: 55,
    image_url: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Science Fiction Collection",
    description: "Epic science fiction stories exploring futuristic worlds, advanced technology, and human imagination.",
    price: 649,
    category: "Books",
    in_stock: 50,
    image_url: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Children's Storybook Collection",
    description: "Beautifully illustrated storybook collection with engaging stories, moral lessons, and colorful artwork.",
    price: 399,
    category: "Books",
    in_stock: 80,
    image_url: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Photography Guide",
    description: "Complete guide to photography covering techniques, composition, lighting, and post-processing.",
    price: 999,
    category: "Books",
    in_stock: 25,
    image_url: "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Poetry Anthology",
    description: "Collection of beautiful poems from renowned poets, exploring themes of love, nature, and life.",
    price: 449,
    category: "Books",
    in_stock: 40,
    image_url: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

// ========== SPORTS (10 products) ==========
db.products.insertMany([
  {
    name: "Yoga Mat Premium",
    description: "Non-slip yoga mat with extra cushioning, eco-friendly material, and carrying strap. Perfect for yoga and fitness.",
    price: 1299,
    category: "Sports",
    in_stock: 70,
    image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Dumbbell Set 10kg",
    description: "Adjustable dumbbell set with comfortable grip, durable construction, and compact design for home workouts.",
    price: 2999,
    category: "Sports",
    in_stock: 45,
    image_url: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Football/Soccer Ball",
    description: "Professional-grade football with perfect bounce, durable outer shell, and official size and weight.",
    price: 899,
    category: "Sports",
    in_stock: 90,
    image_url: "https://images.unsplash.com/photo-1614634712231-8f3b81bcd138?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Tennis Racket",
    description: "Lightweight tennis racket with carbon fiber frame, comfortable grip, and excellent power and control.",
    price: 4999,
    category: "Sports",
    in_stock: 30,
    image_url: "https://images.unsplash.com/photo-1622163642999-9586a0b0c8a2?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Basketball",
    description: "Official size basketball with premium leather, excellent grip, and consistent bounce for indoor and outdoor play.",
    price: 1499,
    category: "Sports",
    in_stock: 65,
    image_url: "https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Resistance Bands Set",
    description: "Complete resistance bands set with multiple resistance levels, door anchor, and exercise guide. Perfect for full-body workouts.",
    price: 799,
    category: "Sports",
    in_stock: 100,
    image_url: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Cricket Bat",
    description: "Professional cricket bat with English willow, perfect balance, and comfortable handle grip.",
    price: 3999,
    category: "Sports",
    in_stock: 40,
    image_url: "https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Badminton Racket Set",
    description: "Lightweight badminton racket with carbon shaft, durable strings, and comfortable grip. Includes shuttlecocks.",
    price: 1999,
    category: "Sports",
    in_stock: 55,
    image_url: "https://images.unsplash.com/photo-1622163642999-9586a0b0c8a2?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Swimming Goggles",
    description: "Anti-fog swimming goggles with UV protection, comfortable silicone seal, and adjustable strap.",
    price: 599,
    category: "Sports",
    in_stock: 85,
    image_url: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Cycling Helmet",
    description: "Safety-certified cycling helmet with ventilation, adjustable fit system, and lightweight design.",
    price: 2499,
    category: "Sports",
    in_stock: 50,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

// ========== HOME & GARDEN (10 products) ==========
db.products.insertMany([
  {
    name: "Indoor Plant Pot Set",
    description: "Beautiful ceramic plant pots with drainage holes, perfect for indoor plants and home decoration.",
    price: 899,
    category: "Home & Garden",
    in_stock: 120,
    image_url: "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "LED Desk Lamp",
    description: "Modern LED desk lamp with adjustable brightness, color temperature control, and USB charging port.",
    price: 1299,
    category: "Home & Garden",
    in_stock: 80,
    image_url: "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Garden Tool Set",
    description: "Complete garden tool set with trowel, pruner, weeder, and gloves. Durable stainless steel construction.",
    price: 1999,
    category: "Home & Garden",
    in_stock: 60,
    image_url: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Throw Pillow Set",
    description: "Soft and comfortable throw pillow set with decorative covers, perfect for living room and bedroom.",
    price: 1499,
    category: "Home & Garden",
    in_stock: 100,
    image_url: "https://images.unsplash.com/photo-1584100936595-c0655c31e1f1?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Wall Clock Modern",
    description: "Sleek modern wall clock with silent movement, large numbers, and contemporary design.",
    price: 799,
    category: "Home & Garden",
    in_stock: 75,
    image_url: "https://images.unsplash.com/photo-1517142089942-b503cd5c5fdc?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Storage Baskets Set",
    description: "Woven storage baskets for organizing home items, stylish design, and multiple sizes included.",
    price: 999,
    category: "Home & Garden",
    in_stock: 90,
    image_url: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Candle Set Aromatherapy",
    description: "Soy wax candles with natural fragrances, long burn time, and elegant glass containers.",
    price: 699,
    category: "Home & Garden",
    in_stock: 110,
    image_url: "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Watering Can Garden",
    description: "Durable plastic watering can with long spout, comfortable handle, and 2-liter capacity.",
    price: 399,
    category: "Home & Garden",
    in_stock: 130,
    image_url: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Table Runner Decorative",
    description: "Elegant table runner with intricate patterns, perfect for dining table decoration and special occasions.",
    price: 599,
    category: "Home & Garden",
    in_stock: 95,
    image_url: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Plant Fertilizer Organic",
    description: "Organic plant fertilizer with essential nutrients, promotes healthy growth, and safe for all plants.",
    price: 349,
    category: "Home & Garden",
    in_stock: 200,
    image_url: "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

// ========== TOYS (10 products) ==========
db.products.insertMany([
  {
    name: "Building Blocks Set",
    description: "Colorful building blocks set with 200+ pieces, encourages creativity, imagination, and fine motor skills.",
    price: 1299,
    category: "Toys",
    in_stock: 80,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Remote Control Car",
    description: "Fast remote control car with 2.4GHz frequency, LED lights, and rechargeable battery. Great for kids and adults.",
    price: 1999,
    category: "Toys",
    in_stock: 50,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Educational Puzzle Set",
    description: "Educational puzzle set with world map, animals, and numbers. Develops problem-solving and cognitive skills.",
    price: 899,
    category: "Toys",
    in_stock: 100,
    image_url: "https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Action Figure Set",
    description: "Detailed action figure set with multiple characters, accessories, and articulation points for dynamic poses.",
    price: 1499,
    category: "Toys",
    in_stock: 65,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Board Game Collection",
    description: "Classic board game collection including chess, checkers, and snakes & ladders. Perfect for family time.",
    price: 999,
    category: "Toys",
    in_stock: 70,
    image_url: "https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Musical Toy Piano",
    description: "Colorful toy piano with 25 keys, multiple sounds, and volume control. Introduces children to music.",
    price: 2499,
    category: "Toys",
    in_stock: 40,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Doll House Set",
    description: "Beautiful doll house with furniture, accessories, and multiple rooms. Encourages imaginative play.",
    price: 3999,
    category: "Toys",
    in_stock: 30,
    image_url: "https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Science Experiment Kit",
    description: "Educational science experiment kit with safe materials, instruction manual, and fun experiments for kids.",
    price: 1999,
    category: "Toys",
    in_stock: 55,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Toy Robot Interactive",
    description: "Interactive toy robot with voice commands, LED lights, and movement. Teaches programming basics.",
    price: 3499,
    category: "Toys",
    in_stock: 35,
    image_url: "https://images.unsplash.com/photo-1606092195730-5d7b9af1efc5?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  },
  {
    name: "Art Supplies Set",
    description: "Complete art supplies set with crayons, markers, paints, brushes, and sketchbook. Perfect for young artists.",
    price: 799,
    category: "Toys",
    in_stock: 90,
    image_url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500&h=500&fit=crop",
    created_at: new Date(),
    updated_at: new Date()
  }
]);

print("\n✅ Successfully inserted products for all categories!");
print("\n📊 Summary:");
print("   Electronics: " + db.products.countDocuments({category: "Electronics"}));
print("   Clothing: " + db.products.countDocuments({category: "Clothing"}));
print("   Groceries: " + db.products.countDocuments({category: "Groceries"}));
print("   Books: " + db.products.countDocuments({category: "Books"}));
print("   Sports: " + db.products.countDocuments({category: "Sports"}));
print("   Home & Garden: " + db.products.countDocuments({category: "Home & Garden"}));
print("   Toys: " + db.products.countDocuments({category: "Toys"}));
print("\n📦 Total Products: " + db.products.countDocuments({}));





