import random
import requests
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from marketplace_api.models import Product, Category
from django.core.files.base import ContentFile

class Command(BaseCommand):
    help = 'Populate the database with fake products and images'

    def add_arguments(self, parser):
        parser.add_argument('--count', type=int, default=20, help='Number of fake products to create')

    def handle(self, *args, **options):
        count = options['count']
        
        # Check if we have any users
        users = User.objects.all()
        if not users.exists():
            self.stdout.write(self.style.ERROR('No users found. Please create some users first.'))
            return
        
        # Check if we have any categories
        categories = Category.objects.all()
        if not categories.exists():
            # Create some default categories
            categories_data = [
                ('Electronics', 'Electronic devices and gadgets'),
                ('Clothing', 'Fashion and apparel'),
                ('Books', 'Books and educational materials'),
                ('Furniture', 'Home and office furniture'),
                ('Sports', 'Sports equipment and accessories'),
                ('Food & Beverages', 'Food and drink products'),
                ('Beauty', 'Beauty and personal care products'),
                ('Toys', 'Toys and games'),
            ]
            
            for name, description in categories_data:
                Category.objects.create(name=name, description=description)
            
            categories = Category.objects.all()
            self.stdout.write(self.style.SUCCESS('Created default categories'))
        
        # Fake product data with relevant image URLs
        fake_products = [
            ('Premium Wireless Headphones', 'High-quality wireless headphones with noise cancellation', 199.99, 'Electronics', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop'),
            ('Organic Cotton T-Shirt', 'Comfortable organic cotton t-shirt in various colors', 29.99, 'Clothing', 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=500&h=500&fit=crop'),
            ('Programming Python Book', 'Comprehensive guide to Python programming', 49.99, 'Books', 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500&h=500&fit=crop'),
            ('Ergonomic Office Chair', 'Adjustable ergonomic chair for home office', 299.99, 'Furniture', 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=500&h=500&fit=crop'),
            ('Professional Yoga Mat', 'Non-slip yoga mat for all skill levels', 39.99, 'Sports', 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500&h=500&fit=crop'),
            ('Artisan Coffee Beans', 'Premium roasted coffee beans from Colombia', 24.99, 'Food & Beverages', 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500&h=500&fit=crop'),
            ('Natural Face Cream', 'Organic face cream with vitamin C', 34.99, 'Beauty', 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&h=500&fit=crop'),
            ('Educational Building Blocks', 'STEM building blocks for kids aged 3-8', 59.99, 'Toys', 'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=500&h=500&fit=crop'),
            ('Smartphone Stand', 'Adjustable aluminum smartphone stand', 19.99, 'Electronics', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop'),
            ('Winter Jacket', 'Waterproof winter jacket with thermal insulation', 129.99, 'Clothing', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500&h=500&fit=crop'),
            ('JavaScript Guide', 'Complete JavaScript programming guide', 44.99, 'Books', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&h=500&fit=crop'),
            ('Standing Desk', 'Height-adjustable standing desk converter', 249.99, 'Furniture', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&h=500&fit=crop'),
            ('Resistance Bands Set', 'Complete set of resistance bands for workouts', 29.99, 'Sports', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=500&fit=crop'),
            ('Green Tea Collection', 'Premium Japanese green tea selection', 22.99, 'Food & Beverages', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500&h=500&fit=crop'),
            ('Vitamin C Serum', 'Anti-aging vitamin C serum for face', 27.99, 'Beauty', 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500&h=500&fit=crop'),
            ('RC Car', 'Remote control car for kids and adults', 89.99, 'Toys', 'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=500&h=500&fit=crop'),
            ('Bluetooth Speaker', 'Portable waterproof Bluetooth speaker', 79.99, 'Electronics', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&h=500&fit=crop'),
            ('Running Shoes', 'Lightweight running shoes for all terrains', 89.99, 'Clothing', 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=500&h=500&fit=crop'),
            ('Mystery Novel', 'Bestselling mystery thriller novel', 19.99, 'Books', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&h=500&fit=crop'),
            ('Bookshelf', 'Modern 5-tier bookshelf for home office', 179.99, 'Furniture', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&h=500&fit=crop'),
        ]
        
        # Create fake products with images
        created_count = 0
        for name, description, price, category_name, image_url in fake_products[:count]:
            try:
                category = categories.get(name=category_name)
                seller = random.choice(users)
                
                # Check if product already exists
                if Product.objects.filter(name=name).exists():
                    self.stdout.write(f"Product '{name}' already exists, updating image...")
                    product = Product.objects.filter(name=name).first()
                else:
                    product = Product.objects.create(
                        seller=seller,
                        category=category,
                        name=name,
                        description=description,
                        price=price,
                        available_quantity=random.randint(10, 100),
                        minimum_order_quantity=1,
                        unit='Pieces',
                        country_of_origin='USA',
                        image='',  # Will be updated with downloaded image
                        is_active=True
                    )
                    created_count += 1
                
                # Download and assign image
                try:
                    response = requests.get(image_url, timeout=10)
                    if response.status_code == 200:
                        # Extract filename from URL
                        filename = f"{name.lower().replace(' ', '_')}.jpg"
                        # Create a ContentFile from the image data
                        image_file = ContentFile(response.content, name=filename)
                        product.image.save(filename, image_file, save=True)
                        self.stdout.write(f'{"Updated" if Product.objects.filter(name=name).exists() else "Created"} product: {name} with image')
                    else:
                        self.stdout.write(self.style.WARNING(f"Failed to download image for {name}: Status code {response.status_code}"))
                except requests.exceptions.RequestException as e:
                    self.stdout.write(self.style.WARNING(f"Error downloading image for {name}: {e}"))
                
            except Category.DoesNotExist:
                self.stdout.write(self.style.WARNING(f'Category {category_name} not found, skipping'))
        
        self.stdout.write(
            self.style.SUCCESS(f'Successfully created {created_count} fake products with images')
        )