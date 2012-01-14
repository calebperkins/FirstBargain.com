class Admin::CategoriesController < Admin::AdminController
  
  def index
    @category = Category.new
    @categories = Category.all
  end
  
  def new
    @category = Category.new
  end
  
  def edit
    @category = Category.find params[:id]
  end
  
  def update
    @category = Category.find params[:id]
    @category.update_attributes(params[:category])
    respond_with :admin, @category, location: admin_categories_url
  end
  
  def create
    @category = Category.new params[:category]
    @category.save
    respond_with :admin, @category, location: admin_categories_url
  end
  
end
