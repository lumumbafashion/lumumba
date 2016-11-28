class CkEditorAssetsController < ActionController::Base

  WHITELIST = Ckeditor.assets.map{|path| path.gsub(/^ckeditor\//, '') } + %w(lang/en.js lang/es.js)

  def serve
    name = "#{params[:asset_name]}.#{params[:format]}"
    if WHITELIST.include?(name)
      redirect_to view_context.asset_path("ckeditor/#{name}")
    else
      head 422
    end
  end

end
