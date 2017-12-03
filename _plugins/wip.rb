module Jekyll
  module Tags
    class WIP < Liquid::Tag
      def render(context)
        "<i class=\"fa fa-spinner fa-spin\"></i>"
      end
    end
  end
end

Liquid::Template.register_tag('wip', Jekyll::Tags::WIP)
