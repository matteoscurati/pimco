require 'uglifier'

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

all_articles = data.article

all_articles.article.each do |article|
  proxy "/articoli/#{article.slug}.html", "/templates/article.html", ignore: true, locals: { article: article }
end

# Localization
# activate :i18n

# Assets
set :css_dir, 'dist/stylesheets'
set :js_dir, 'dist/javascripts'
set :images_dir, 'dist/images'

# External pipeline
activate :external_pipeline,
  name: :gulp,
  command: build? ? 'gulp build --production' : './node_modules/gulp/bin/gulp.js',
  source: "dist",
  latency: 1

set :relative_links, true

# Build-specific configuration
configure :build do
  ignore 'assets/*'
  activate :gzip
  activate :minify_html, remove_intertag_spaces: true
  activate :asset_hash
  activate :relative_assets
end

TRANSFORMS = [
  ['à', '&agrave;'],
  ['è', '&egrave;'],
  ['ù', '&ugrave;'],
  ['ò', '&ograve;'],
  ['ì', '&igrave;'],
  ['À', '&Agrave;'],
  ['È', '&Egrave;'],
  ['Ù', '&Ugrave;'],
  ['Ò', '&Ograve;'],
  ['Ì', '&Igrave;'],
  ['°', '&deg;'],
  ['«', '&laquo;'],
  ['»', '&raquo;'],
  ['É', '&Eacute;'],
  ['é', '&eacute;']
]

#helpers
helpers do
  def markdown(text)
    renderer = Redcarpet::Render::HTML.new
    Redcarpet::Markdown.new(renderer).render(text)
  end

  def entity(text)
    TRANSFORMS.each.with_object(text) { |(from, to), t| t = t.gsub!(from, to) }
  end

  def download_image(url)
    html = Nokogiri::HTML(url)
    string = html.css("img").attribute('src').to_s
    File.open("build/urls.txt", 'a') { |file| file.puts string }
  end
end
