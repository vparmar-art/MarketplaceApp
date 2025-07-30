from django.contrib import admin
from .models import (
    Category, Product, ProductImage, ProductSpecification, Review, 
    Order, OrderItem, OrderDocument, UserProfile
)


class ProductImageInline(admin.TabularInline):
    model = ProductImage
    extra = 1


class ProductSpecificationInline(admin.TabularInline):
    model = ProductSpecification
    extra = 1


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'seller', 'category', 'price', 'available_quantity', 'is_active', 'created_at')
    list_filter = ('is_active', 'category', 'created_at')
    search_fields = ('name', 'description', 'seller__username', 'category__name')
    inlines = [ProductImageInline, ProductSpecificationInline]


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('product', 'quantity', 'price')


class OrderDocumentInline(admin.TabularInline):
    model = OrderDocument
    extra = 1


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'total_amount', 'status', 'destination_country', 'created_at')
    list_filter = ('status', 'created_at', 'destination_country')
    search_fields = ('user__username', 'shipping_address', 'notes')
    inlines = [OrderItemInline, OrderDocumentInline]
    readonly_fields = ('total_amount',)


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'created_at')
    search_fields = ('name', 'description')


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('product', 'user', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('product__name', 'user__username', 'comment')


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'company_name', 'user_type', 'country', 'verified')
    list_filter = ('user_type', 'verified', 'country')
    search_fields = ('user__username', 'company_name', 'phone_number')
