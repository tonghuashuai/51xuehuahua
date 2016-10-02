(function() {
  new Vue({
    el: '#login-form',
    data: {
      user_name: '',
      password: ''
    },
    methods: {
      submit: function() {
        if (this.user_name && this.password) {
          return $._ajax({
            url: '/j/login',
            method: 'POST',
            data: this.$data,
            success: function() {
              return window.location.href = '/';
            }
          });
        }
      }
    }
  });

}).call(this);
