---
layout: default
permalink: /notes/
---

<div class="posts">
  {% for post in site.posts %}
  {% if post.category contains "notes" %}
    <article class="post">

      <h1><a href="{{ site.baseurl }}{{ post.url }}">{{ post.title }}</a></h1>

      <div class="entry">
        {{ post.excerpt }}
      </div>

      <a href="{{ site.baseurl }}{{ post.url }}" class="button button-primary">Read More</a>
    </article>
  {% endif %}
  {% endfor %}
</div>
