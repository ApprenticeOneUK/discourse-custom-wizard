import { trustHTML } from "@ember/template";
import DRelativeDate from "discourse/ui-kit/d-relative-date";

export default <template>
  <a href={{@topic.url}} target="_blank" rel="noopener noreferrer">
    <span class="title">{{trustHTML @topic.fancy_title}}</span>
    <div class="blurb">
      <DRelativeDate @date={{@topic.created_at}} />
      -
      {{trustHTML @topic.blurb}}
    </div>
  </a>
</template>
