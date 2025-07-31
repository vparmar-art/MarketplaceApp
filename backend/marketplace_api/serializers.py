from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    Category, Product, ProductSpecification, Review, 
    Order, OrderItem, OrderDocument, UserProfile
)


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']
        read_only_fields = ['id']


class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = UserProfile
        fields = [
            'id', 'user', 'company_name', 'company_website', 'user_type',
            'country', 'phone_number', 'address', 'profile_picture',
            'business_registration_number', 'tax_id', 'industry', 'verified'
        ]
        read_only_fields = ['id', 'verified']


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'description', 'image', 'created_at']
        read_only_fields = ['id', 'created_at']


# ProductImageSerializer removed - using only the image field in Product model


class ProductSpecificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductSpecification
        fields = ['id', 'name', 'value']
        read_only_fields = ['id']


class ReviewSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Review
        fields = ['id', 'user', 'rating', 'comment', 'created_at']
        read_only_fields = ['id', 'created_at']


class ProductSerializer(serializers.ModelSerializer):
    seller = UserSerializer(read_only=True)
    category = CategorySerializer(read_only=True)
    category_id = serializers.PrimaryKeyRelatedField(
        queryset=Category.objects.all(),
        write_only=True
    )
    specifications = ProductSpecificationSerializer(many=True, read_only=True)
    reviews = ReviewSerializer(many=True, read_only=True)
    average_rating = serializers.SerializerMethodField()
    image = serializers.SerializerMethodField()

    def get_image(self, obj):
        # Check if the image field has a file
        if obj.image and hasattr(obj.image, 'url') and obj.image.name:
            request = self.context.get('request')
            if request is not None:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None
    
    class Meta:
        model = Product
        fields = [
            'id', 'seller', 'category', 'category_id', 'name', 'description',
            'price', 'minimum_order_quantity', 'available_quantity', 'unit',
            'country_of_origin', 'shipping_terms', 'lead_time', 'certifications',
            'image', 'is_active', 'created_at', 'updated_at',
            'specifications', 'reviews', 'average_rating'
        ]
        read_only_fields = ['id', 'seller', 'created_at', 'updated_at']
    
    def get_average_rating(self, obj):
        reviews = obj.reviews.all()
        if reviews.exists():
            return sum(review.rating for review in reviews) / reviews.count()
        return 0
    
    def create(self, validated_data):
        category_id = validated_data.pop('category_id')
        validated_data['category'] = category_id
        validated_data['seller'] = self.context['request'].user
        return super().create(validated_data)


class OrderItemSerializer(serializers.ModelSerializer):
    product = ProductSerializer(read_only=True)
    product_id = serializers.PrimaryKeyRelatedField(
        queryset=Product.objects.all(),
        write_only=True
    )
    
    class Meta:
        model = OrderItem
        fields = ['id', 'product', 'product_id', 'quantity', 'price']
        read_only_fields = ['id', 'price']


class OrderDocumentSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderDocument
        fields = ['id', 'document_type', 'document', 'description', 'uploaded_at']
        read_only_fields = ['id', 'uploaded_at']


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    documents = OrderDocumentSerializer(many=True, read_only=True)
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = Order
        fields = [
            'id', 'user', 'items', 'documents', 'total_amount', 'shipping_address',
            'destination_country', 'destination_port', 'shipping_terms', 'payment_terms',
            'status', 'notes', 'estimated_delivery_date', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'user', 'total_amount', 'created_at', 'updated_at']
    
    def create(self, validated_data):
        # This will be called from the express_interest endpoint in ProductViewSet
        # The actual implementation is in the view
        return super().create(validated_data)