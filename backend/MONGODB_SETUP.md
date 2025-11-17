# MongoDB Product Setup Guide

This guide will help you insert products into your MongoDB database.

## Quick Start

### Option 1: Using MongoDB Shell (mongosh)

1. **Open MongoDB Shell:**
   ```bash
   mongosh
   ```

2. **Run the script:**
   ```bash
   mongosh < mongodb_all_categories_insert.js
   ```
   
   Or copy and paste the commands from `mongodb_all_categories_insert.js` directly into mongosh.

### Option 2: Using MongoDB Compass

1. Open MongoDB Compass
2. Connect to your database
3. Navigate to the `products` collection
4. Click "Insert Document"
5. Copy and paste the product documents from the script

### Option 3: Using Python Script

You can also use the backend API endpoint:
```bash
POST http://localhost:8000/products
```

## Product Categories Included

- **Electronics** (10 products)
- **Clothing** (10 products)
- **Groceries** (10 products)
- **Books** (10 products)
- **Sports** (10 products)
- **Home & Garden** (10 products)
- **Toys** (10 products)

**Total: 70 products**

## Product Structure

Each product has the following fields:
- `name`: Product name
- `description`: Product description
- `price`: Price in Indian Rupees (₹)
- `category`: Product category (must match one of the predefined categories)
- `in_stock`: Stock quantity
- `image_url`: Product image URL (using Unsplash)
- `created_at`: Creation timestamp
- `updated_at`: Update timestamp

## Verify Products

After insertion, verify in MongoDB shell:
```javascript
use('e-commerce-app');
db.products.countDocuments({});
db.products.find({category: "Electronics"}).pretty();
```

## Notes

- Make sure your MongoDB is running
- Database name: `e-commerce-app` (or change in script if different)
- Collection name: `products`
- All products use realistic prices in Indian Rupees
- Image URLs are from Unsplash (free stock photos)





