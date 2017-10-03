module Jekyll
  module Tags
    class FoldHlBlock < HighlightBlock
      def render(context)
        "<details><summary>Code</summary>" + super + "</details>"
      end
    end
  end
end

Liquid::Template.register_tag("foldhl", Jekyll::Tags::FoldHlBlock)
Liquid::Template.register_tag("hl", Jekyll::Tags::HighlightBlock)
