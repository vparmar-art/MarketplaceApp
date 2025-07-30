from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator


class Category(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    image = models.ImageField(upload_to='categories/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name
    
    class Meta:
        verbose_name_plural = 'Categories'


class Product(models.Model):
    seller = models.ForeignKey(User, on_delete=models.CASCADE, related_name='products')
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='products')
    name = models.CharField(max_length=200)
    description = models.TextField()
    price = models.DecimalField(max_digits=10, decimal_places=2)
    minimum_order_quantity = models.PositiveIntegerField(default=1, help_text='Minimum quantity that can be ordered')
    available_quantity = models.PositiveIntegerField(default=0, help_text='Total available quantity for export')
    unit = models.CharField(max_length=50, help_text='Unit of measurement (e.g., Tons, Containers, Pieces)')
    country_of_origin = models.CharField(max_length=100)
    shipping_terms = models.TextField(help_text='FOB, CIF, etc.', blank=True, null=True)
    lead_time = models.CharField(max_length=100, help_text='Estimated time for delivery', blank=True, null=True)
    certifications = models.TextField(blank=True, null=True, help_text='ISO, CE, FDA, etc.')
    image = models.ImageField(upload_to='products/')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return self.name


class ProductImage(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='products/')
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Image for {self.product.name}"


class ProductSpecification(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='specifications')
    name = models.CharField(max_length=100, help_text='Specification name (e.g., Material, Size, Weight)')
    value = models.CharField(max_length=255, help_text='Specification value')
    
    def __str__(self):
        return f"{self.name}: {self.value} for {self.product.name}"


class Review(models.Model):
    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='reviews')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='reviews')
    rating = models.PositiveSmallIntegerField(validators=[MinValueValidator(1), MaxValueValidator(5)])
    comment = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Review by {self.user.username} for {self.product.name}"
    
    class Meta:
        unique_together = ('product', 'user')


class Order(models.Model):
    STATUS_CHOICES = (
        ('inquiry', 'Inquiry'),
        ('negotiation', 'Negotiation'),
        ('confirmed', 'Confirmed'),
        ('production', 'In Production'),
        ('quality_check', 'Quality Check'),
        ('shipping', 'Shipping'),
        ('delivered', 'Delivered'),
        ('cancelled', 'Cancelled'),
    )
    
    PAYMENT_TERMS = (
        ('letter_of_credit', 'Letter of Credit (L/C)'),
        ('telegraphic_transfer', 'Telegraphic Transfer (T/T)'),
        ('documentary_collection', 'Documentary Collection (D/P, D/A)'),
        ('open_account', 'Open Account'),
        ('advance_payment', 'Advance Payment'),
    )
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders')
    total_amount = models.DecimalField(max_digits=15, decimal_places=2)
    shipping_address = models.TextField()
    destination_country = models.CharField(max_length=100)
    destination_port = models.CharField(max_length=100, blank=True, null=True)
    shipping_terms = models.CharField(max_length=100, blank=True, null=True, help_text='FOB, CIF, etc.')
    payment_terms = models.CharField(max_length=50, choices=PAYMENT_TERMS, blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='inquiry')
    notes = models.TextField(blank=True, null=True, help_text='Additional information or requirements')
    estimated_delivery_date = models.DateField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Order #{self.id} by {self.user.username}"


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)
    price = models.DecimalField(max_digits=15, decimal_places=2)  # Price at the time of purchase
    
    def __str__(self):
        return f"{self.quantity} {self.product.unit} of {self.product.name} in Order #{self.order.id}"


class OrderDocument(models.Model):
    DOCUMENT_TYPES = (
        ('invoice', 'Commercial Invoice'),
        ('packing_list', 'Packing List'),
        ('bill_of_lading', 'Bill of Lading'),
        ('certificate_of_origin', 'Certificate of Origin'),
        ('inspection_certificate', 'Inspection Certificate'),
        ('insurance', 'Insurance Document'),
        ('other', 'Other Document'),
    )
    
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='documents')
    document_type = models.CharField(max_length=50, choices=DOCUMENT_TYPES)
    document = models.FileField(upload_to='order_documents/')
    description = models.CharField(max_length=255, blank=True, null=True)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.get_document_type_display()} for Order #{self.order.id}"


class UserProfile(models.Model):
    USER_TYPES = (
        ('exporter', 'Exporter'),
        ('buyer', 'International Buyer'),
        ('both', 'Both'),
    )
    
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    company_name = models.CharField(max_length=200, blank=True, null=True)
    company_website = models.URLField(blank=True, null=True)
    user_type = models.CharField(max_length=20, choices=USER_TYPES, default='buyer')
    country = models.CharField(max_length=100, blank=True, null=True)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)
    business_registration_number = models.CharField(max_length=100, blank=True, null=True)
    tax_id = models.CharField(max_length=100, blank=True, null=True)
    industry = models.CharField(max_length=100, blank=True, null=True)
    verified = models.BooleanField(default=False)
    
    def __str__(self):
        return f"Profile for {self.user.username}"
