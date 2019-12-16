import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import { Datetime } from 'vue-datetime'
// You need a specific loader for CSS files
import 'vue-datetime/dist/vue-datetime.css'

Vue.use(Datetime)
Vue.use(TurbolinksAdapter)

document.addEventListener('turbolinks:load', () => {
  // conditionally initializing vue
  // if appropiate page exist becouse of rails turbolinks
  var element = document.getElementById("form-app")

  if (element != null) {
    const app = new Vue({
      el: '#form-app',
      data: () => {
        return {
          datetime: startTime,
          activityTypes: activityTypes,
          activityTypeSelected: activityTypeSelected,
        }
      },

      methods: {
        itemClicked(item){
          this.activityTypeSelected = item.id;
        }
      },

      // components: { App }
      components: {
        datetime: Datetime
      }
    })
  }
})
