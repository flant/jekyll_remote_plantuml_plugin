# Jekyll Remote PlantUML Plugin

The plugin includes local/remote PlantUML diagrams into your pages, works only with an external PlantUML server 
(http://www.plantuml.com/plantuml by default) — PlantUML jar installed locally not required.

## Usage

To add a diagram to the page, use the `plantuml` tag:
```text
{% plantuml %}
Bob -> Alice : Hello 
{% endplantuml %}
```

The result will be the following html:

```html
<div class="plantuml">
    <img src="http://www.plantuml.com/plantuml/svg/SyfFKj2rKt3CoKnELR1Iy4ZDoSa70000" class="plantuml" />
</div>
```

In case images are loaded during site rendering (see more in [Configuration section](#Configuration)):

```html
<div class="plantuml">
    <img src="/plantuml/e1a0ca2ce15d9bed48f357fab712a76e6b1c7954.svg" class="plantuml" />
</div>
```

The following list of tag parameters allows to set attributes for `div` and `img` tags:
- `div_class`
- `div_style`
- `img_class`
- `img_style`
- `img_width`
- `img_height`
- `img_alt`

For example:

```text
{% plantuml div_style="text-align: center" img_alt="Diagram: Bob greets Alice"  %}
Bob -> Alice : Hello 
{% endplantuml %}
```

```html
<div class="plantuml" style="text-align: center">
    <img src="/plantuml/e1a0ca2ce15d9bed48f357fab712a76e6b1c7954.svg" class="plantuml" alt="Diagram: Bob greets Alice" />
</div>
```

## Configuration

In the configuration file, you can override the preset values and define defaults for format, div and img tags 
attributes.

Below are the supported parameters and their defaults:
```yaml
plantuml:
  provider: 'http://www.plantuml.com/plantuml'
  
  # default format: svg or png
  format: 'svg',
  
  # load an image from the server during site rendering and only if
  # the image does not already exist in the cache directory (disabled by default)
  save_images_locally: false,
  cache_dir: 'plantuml',
  
  # default div tag attributes
  div_class: 'plantuml',
  div_style: ''
  
  # default img tag attributes
  img_class: 'plantuml'
  img_style: '' 
  img_id: ''
  img_width: ''
  img_height: '' 
  img_alt: ''
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll_remote_plantuml_plugin'
```

And this into your Jekyll config:
```yaml
plugins:
  - jekyll_remote_plantuml_plugin
```

Then execute:
```bash
bundle install
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
