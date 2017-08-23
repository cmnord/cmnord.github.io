---
layout: page
permalink: /projects
title: Projects
---
<ul class="posts">
  {% for proj in site.data.projects %}

    <li itemscope>
      <h3>{{ proj.title }}</h3>
      <p class="post-date"><span>
        {% if proj.date %}
            <i class="fa fa-calendar" aria-hidden="true"></i> {{ proj.date }}
        {% else %}
            <i class="fa fa-hourglass-2" aria-hidden="true"></i> In progress
        {% endif %}
        {% if proj.github %}
             - 
             <i class="fa fa-github" aria-hidden="true"></i> <a href="https://github.com/{{ proj.github }}">GitHub</a>
        {% endif %}
        {% if proj.website %}
             - 
             <i class="fa fa-link" aria-hidden="true"></i> <a href="{{ proj.website }}">Website</a>
        {% endif %}
      </span></p>
      {% if proj.img %}
        <img class="project-img" src="{{ proj.img }}"/>
      {% else %}
        <img class="project-img" src="https://placebear.com/1024/380" title="Image coming soon! ʕ•ᴥ•ʔ"/>
      {% endif %}
      <p>{{ proj.info }}</p>
    </li>

  {% endfor %}
</ul>
