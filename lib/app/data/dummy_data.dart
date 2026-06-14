/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import 'models/product_model.dart';
import 'models/other_models.dart';

final List<CategoryItem> categoriesList = [
  CategoryItem(
    id: 'sofas',
    title: 'Sofas',
    image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'beds',
    title: 'Beds',
    image: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'dining',
    title: 'Dining Sets',
    image: 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'tv_units',
    title: 'TV Units',
    image: 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'coffee_tables',
    title: 'Coffee Tables',
    image: 'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'recliner_sofas',
    title: 'Recliners',
    image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'lounge_chairs',
    title: 'Lounge Chairs',
    image: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'shoe_racks',
    title: 'Shoe Racks',
    image: 'https://images.unsplash.com/photo-1518051870910-a46e5443d112?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'cabinets',
    title: 'Cabinets',
    image: 'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=200&auto=format&fit=crop&q=80',
  ),
  CategoryItem(
    id: 'bookshelves',
    title: 'Bookshelves',
    image: 'https://images.unsplash.com/photo-1594620302200-9a762244a156?w=200&auto=format&fit=crop&q=80',
  ),
];

final List<BannerItem> bannerCarouselCount = [
  BannerItem(
    id: 'b1',
    title: 'Summer Season Sale',
    subtitle: 'Lounge Chairs Starting From ₹5,999',
    image: 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=800&auto=format&fit=crop&q=80',
    promoText: 'UPTO 60% OFF',
  ),
  BannerItem(
    id: 'b2',
    title: 'Entire Bedroom Setup',
    subtitle: 'Starting at ₹38,999',
    image: 'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800&auto=format&fit=crop&q=80',
    promoText: '15-Year Warranty',
  ),
  BannerItem(
    id: 'b3',
    title: 'Watch. Store. Style.',
    subtitle: 'TV Units Starting From ₹1,999',
    image: 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800&auto=format&fit=crop&q=80',
    promoText: 'Limited Stock Offer',
  ),
];

final List<GridCategory> brandGridCategories = [
  GridCategory(
    id: 'grid_sofas',
    title: 'Sofas',
    image: 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=300&auto=format&fit=crop&q=80',
  ),
  GridCategory(
    id: 'grid_beds',
    title: 'Beds',
    image: 'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=300&auto=format&fit=crop&q=80',
  ),
  GridCategory(
    id: 'grid_dining',
    title: '6 Seater Dining',
    image: 'https://images.unsplash.com/photo-1615066390971-03e4e1c36ddf?w=300&auto=format&fit=crop&q=80',
  ),
  GridCategory(
    id: 'grid_study',
    title: 'All Study Tables',
    image: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=300&auto=format&fit=crop&q=80',
  ),
  GridCategory(
    id: 'grid_balcony',
    title: 'Balcony Furniture',
    image: 'https://images.unsplash.com/photo-1532372320978-9b4d1a358f4c?w=300&auto=format&fit=crop&q=80',
  ),
  GridCategory(
    id: 'grid_kitchen',
    title: 'Kitchen Cabinets',
    image: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=300&auto=format&fit=crop&q=80',
  ),
];

final List<Product> discoverNewProducts = [
  Product(
    id: 'p1',
    name: 'Ayaana Sheesham Wood 3 Seater Sofa Cum Bed with Cane Weaving',
    brand: 'Iron Street Premium',
    price: 65999,
    oldPrice: 146999,
    discount: 55,
    rating: 4.8,
    reviewsCount: 151,
    image: 'https://images.unsplash.com/photo-1540518814984-8541980637d2?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1540518814984-8541980637d2?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'Transform your living room into an elegant guest bedroom with the premium, strong, durable Ayaana Sheesham wood sofa cum bed. It features beautiful honey-finish cane weaving panels and thick high-resilience foam cushioning.',
    deliveryText: 'Ships in 2 Days',
    dimensions: 'H 32 x W 76 x D 35 (Sofa mode), opens to 72 inches width Mattress',
    material: 'Premium Sheesham Wood with Honey Finish Cane',
    category: 'Living',
  ),
  Product(
    id: 'p2',
    name: 'Albus 3 Seater Fabric Sofa (Jade Ivory Finish)',
    brand: 'LuxeLiving by Iron Street',
    price: 37999,
    oldPrice: 64999,
    discount: 41,
    rating: 4.6,
    reviewsCount: 14,
    image: 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'This ultra-luxurious, cozy Albus three-seater sofa boasts high-tensile strength support structures, modern velvet fabric padding in elegant ivory white, and deep soft seat cushions for your cozy evening conversations.',
    deliveryText: 'Ships in 5 Days',
    dimensions: 'H 30 x W 82 x D 34 Inches',
    material: 'Moisture-treated Solid Wood frame & Velvet upholstery',
    category: 'Living',
  ),
  Product(
    id: 'p3',
    name: 'Serena Mango Wood Compact TV Unit with Cane Weaving Doors',
    brand: 'Iron Street Premium',
    price: 14999,
    oldPrice: 24999,
    discount: 40,
    rating: 4.7,
    reviewsCount: 42,
    image: 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'A beautiful compact media center with ample shelf space, wire cutouts, and charming sliding woven cane doors. Engineered with moisture-proof premium solid mango wood.',
    deliveryText: 'Ships in 3 Days',
    dimensions: 'H 18 x W 48 x D 15 Inches',
    material: 'Solid Mango Wood & Premium Natural Rattan Cane',
    category: 'Living',
  ),
  Product(
    id: 'p4',
    name: 'Castor Solid Wood King Size Bed with Hydraulic Storage',
    brand: 'Iron Street Sleep',
    price: 49999,
    oldPrice: 89999,
    discount: 44,
    rating: 4.9,
    reviewsCount: 88,
    image: 'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'Experience effortless storage with our engineered pneumatic hydraulic system. Elegant tall teak headboard padded with ergonomic comfort fabric.',
    deliveryText: 'Ships in 7 Days',
    dimensions: 'L 84 x W 78 x H 44 Inches (King Size)',
    material: 'Premium Grade Teak Solid Wood',
    category: 'Bedroom',
  )
];

final List<Product> topRatedProducts = [
  Product(
    id: 'p5',
    name: 'Osbert 3 Seater Curved Sofa (Cotton, Jade Ivory Finish)',
    brand: 'LuxeLiving by Iron Street',
    price: 39999,
    oldPrice: 69999,
    discount: 42,
    rating: 4.9,
    reviewsCount: 278,
    image: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'Add fluid elegance to your living room. The Osbert Curved Sofa features organic waves, tailored cotton fabric upholstery, and pocket-spring structure providing medium-firm plush comfort.',
    deliveryText: 'Ships in 4 Days',
    dimensions: 'H 31 x W 88 x D 38 Inches',
    material: 'Premium Breathable Cotton Fabric, Strong ply & Solid pinewood core',
    category: 'Living',
  ),
  Product(
    id: 'p6',
    name: 'Mcbeth Premium 4 Seater Dining Table Set with Cushioned Chairs',
    brand: 'Iron Street Premium',
    price: 32999,
    oldPrice: 59999,
    discount: 45,
    rating: 4.8,
    reviewsCount: 164,
    image: 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=500&auto=format&fit=crop&q=80',
      'https://images.unsplash.com/photo-1615066390971-03e4e1c36ddf?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'Enjoy delicious family meals! Craftsmanship meets utility in this beautiful solid dining console complete with four premium tufted cushion seats.',
    deliveryText: 'Ships in 3 Days',
    dimensions: 'Table: H 30 x W 48 x D 36 Inches, Chair: H 38 x W 18 x D 18 Inches',
    material: 'Solid Indian Rosewood (Sheesham)',
    category: 'Dining',
  ),
  Product(
    id: 'p7',
    name: 'Adrian Solid Wood Study Desk with Cable Glands',
    brand: 'Iron Street Work',
    price: 11499,
    oldPrice: 19999,
    discount: 42,
    rating: 4.7,
    reviewsCount: 75,
    image: 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'Boasting modular pull-out drawers, smart charging cable compartments, and sleek minimal wooden legs, Adrian desk keeps your productivity flawless.',
    deliveryText: 'Ships in 2 Days',
    dimensions: 'H 30 x W 45 x D 22 Inches',
    material: 'Sheesham Solid Wood & Solid Iron Screws',
    category: 'Bedroom',
  )
];

final List<FurnishingItem> homeFurnishingGrid = [
  FurnishingItem(
    id: 'f1',
    title: 'Sofa Covers',
    priceText: 'From ₹749',
    image: 'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=300&auto=format&fit=crop&q=80',
  ),
  FurnishingItem(
    id: 'f2',
    title: 'Chair Covers',
    priceText: 'From ₹249',
    image: 'https://images.unsplash.com/photo-1501876725168-00c445821c9e?w=300&auto=format&fit=crop&q=80',
  ),
  FurnishingItem(
    id: 'f3',
    title: 'Bed Sheets',
    priceText: 'From ₹999',
    image: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=300&auto=format&fit=crop&q=80',
  ),
  FurnishingItem(
    id: 'f4',
    title: 'Cushion Covers',
    priceText: 'From ₹299',
    image: 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=300&auto=format&fit=crop&q=80',
  ),
  FurnishingItem(
    id: 'f5',
    title: 'Mattress Protectors',
    priceText: 'From ₹799',
    image: 'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=300&auto=format&fit=crop&q=80',
  ),
  FurnishingItem(
    id: 'f6',
    title: 'Carpets & Rugs',
    priceText: 'From ₹749',
    image: 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?w=300&auto=format&fit=crop&q=80',
  ),
];

final List<DecorItem> homeDecorGrid = [
  DecorItem(
    id: 'd1',
    title: 'Mirrors',
    priceText: 'From ₹989',
    image: 'https://images.unsplash.com/photo-1618220179428-22790b461013?w=300&auto=format&fit=crop&q=80',
  ),
  DecorItem(
    id: 'd2',
    title: 'Serving Trays',
    priceText: 'From ₹605',
    image: 'https://images.unsplash.com/photo-1531315630201-bb15abeb1653?w=300&auto=format&fit=crop&q=80',
  ),
  DecorItem(
    id: 'd3',
    title: 'Figurines',
    priceText: 'From ₹375',
    image: 'https://images.unsplash.com/photo-1606744824163-985d376605aa?w=300&auto=format&fit=crop&q=80',
  ),
  DecorItem(
    id: 'd4',
    title: 'Wall Paintings',
    priceText: 'From ₹2799',
    image: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=300&auto=format&fit=crop&q=80',
  ),
  DecorItem(
    id: 'd5',
    title: 'Vases',
    priceText: 'From ₹309',
    image: 'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=300&auto=format&fit=crop&q=80',
  ),
  DecorItem(
    id: 'd6',
    title: 'Artificial Flowers',
    priceText: 'From ₹169',
    image: 'https://images.unsplash.com/photo-1508781197106-d8c535dcf276?w=300&auto=format&fit=crop&q=80',
  ),
];

final List<Product> recentProducts = [
  Product(
    id: 'p8',
    name: 'Bohemian Mirror Collage (Honey Finish)',
    brand: 'Earthy Homes by Iron Street',
    price: 4599,
    oldPrice: 6999,
    discount: 34,
    rating: 4.6,
    reviewsCount: 278,
    image: 'https://images.unsplash.com/photo-1618220179428-22790b461013?w=500&auto=format&fit=crop&q=80',
    images: [
      'https://images.unsplash.com/photo-1618220179428-22790b461013?w=500&auto=format&fit=crop&q=80'
    ],
    description: 'Add a splash of organic symmetry and tribal artistry to your entrance, hallway, or dining space with our signature Bohemian Mirror set with durable Teak frames.',
    deliveryText: 'Ships in 2 Days',
    dimensions: 'H 24 x W 24 x D 2.5 Inches',
    material: 'Bohemian Crafted Teakwood Frame & Premium HD Float Mirror Glass',
    category: 'Living',
  )
];

final List<Product> allAvailableProducts = [
  ...discoverNewProducts,
  ...topRatedProducts,
  ...recentProducts,
];

final List<ExperienceStore> experienceStores = [
  ExperienceStore(
    id: 's1',
    name: 'Iron Street Experience Store - Bangalore Outer Ring Rd',
    address: 'Survey No. 70, Outer Ring Rd, Marathahalli, Devarabisanahalli, Bengaluru, Karnataka 560103',
    city: 'Bangalore',
    timings: '11:00 AM - 9:00 PM',
    phone: '+91 80 1234 5678',
    image: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400&auto=format&fit=crop&q=80',
  ),
  ExperienceStore(
    id: 's2',
    name: 'Iron Street Experience Store - Mumbai Kherwadi',
    address: 'Ground Floor, Signature Towers, Kherwadi Road, Bandra East, Mumbai, Maharashtra 400051',
    city: 'Mumbai',
    timings: '11:00 AM - 9:00 PM',
    phone: '+91 22 8765 4321',
    image: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&auto=format&fit=crop&q=80',
  ),
  ExperienceStore(
    id: 's3',
    name: 'Iron Street Experience Store - New Delhi Kirti Nagar',
    address: 'Plot No. 12, Kirti Nagar Industrial Area, Near Metro Pillar 321, New Delhi 110015',
    city: 'New Delhi',
    timings: '11:00 AM - 9:00 PM',
    phone: '+91 11 4455 6677',
    image: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=400&auto=format&fit=crop&q=80',
  ),
];
