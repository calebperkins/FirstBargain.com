class Admin::ProductsController < Admin::AdminController
  cache_sweeper :product_sweeper

  def index
    @active = Product.where(discontinued: false).order('products.name ASC')
    @inactive = Product.where(discontinued: true).order('products.name ASC')
    respond_with [@active, @inactive]
  end

  def show
    @product = Product.find(params[:id])
    respond_with @product
  end

  def new
    @categories = Category.order('categories.name ASC')
    @product = Product.new
    4.times {@product.pictures.build}
    respond_with @product
  end

  def edit
    @product = Product.find(params[:id])
    #(4 - @product.pictures.size).times {@product.pictures.build}
    respond_with @product
  end

  def create
    @product = Product.new(params[:product])
    unless @product.save
      @categories = Category.order('categories.name ASC')
      (4 - @product.pictures.size).times {@product.pictures.build}
    end
    respond_with @product, location: [:admin, @product]
  end

  def update
    @product = Product.find(params[:id])
    @product.update_attributes(params[:product])
    respond_with @product, location: [:admin, @product]
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    respond_with @product
  end
  
end
