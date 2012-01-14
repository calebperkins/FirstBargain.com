class ProductsController < ApplicationController
  set_tab :store
  caches_action :index, cache_path: :index_cache, layout: false
  caches_action :show, cache_path: :show_cache, layout: false

  def index
    @products = Product.store.paginate(page: params[:page], per_page: 12)
    respond_with @products
  end

  def show
    @product = Product.store.find(params[:id])
    respond_with @product
  end
  
  private
  
  def index_cache_url
    "member-shop/index/#{params[:page] || 1}/#{logged_in? ? current_user.points.cents : 'none'}"
  end
  
  def show_cache_url
    "member-shop/show/#{params[:id]}/#{logged_in? ? current_user.points.cents : 'none'}"
  end

end
