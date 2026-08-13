---
layout: default
title: Home
permalink: /
---

:stars: [Jynnie][jynnie], [Manuel][manuel], and I are starting something new in the Y Combinator
spring 2026 batch.

:apple: I previously worked on Operating Systems security at [Apple][apple].
Before that, I worked on performance infrastructure and the alerts platform at
[Samsara][samsara].

:turtle: I completed my S.B. and M.Eng in Computer Science at MIT. My M.Eng
[thesis](/research) was on Software Transactional Memory (STM) for real-time
systems with the MIT Lincoln Lab [Resilient Mission Computer][rmc] group.

{% assign latest_post = site.posts.first %}
{% if latest_post %}
<section class="home-latest" aria-labelledby="home-latest-heading">
  <h5 id="home-latest-heading">Latest blog post</h5>
  <article class="home-latest-card">
    <a class="home-latest-link" href="{{ latest_post.url | relative_url }}">
      {% if latest_post.image %}
      <div class="home-latest-image">
        {% include post-image.html post=latest_post %}
      </div>
      {% endif %}
      <div class="home-latest-content">
        <h2 class="home-latest-title">
          {% include post-title.html post=latest_post %}
        </h2>
        {% assign latest_description = latest_post.description | default: latest_post.excerpt | markdownify | remove: '<p>' | remove: '</p>' | strip %}
        <p class="home-latest-description">{{ latest_description }}</p>
        <p class="home-latest-meta">
          <time datetime="{{ latest_post.date | date_to_xmlschema }}">{{ latest_post.date | date: "%B %-d, %Y" }}</time>
          <span aria-hidden="true">&bull;</span>
          {% assign post = latest_post %}
          <span>{% include read-time.html %}</span>
        </p>
      </div>
    </a>
  </article>
  <p><a href="{{ '/blog' | relative_url }}">See all posts &rarr;</a></p>
</section>
{% endif %}

[jynnie]: https://jynnie.me
[manuel]: https://www.linkedin.com/in/manuelccastro/
[apple]: https://support.apple.com/guide/security/welcome/web
[samsara]: https://samsara.com
[aclima]: https://aclima.io/
[rmc]: https://www.ll.mit.edu/r-d/projects/resilient-mission-computer
