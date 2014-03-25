# http://stackoverflow.com/questions/19498174/angularjs-with-packery-js
window.HNTab.directive "dannyPackery", ["$rootScope", ($rootScope) ->
  return {
    link: (scope, element, attrs) ->

      if $rootScope.packery == undefined or $rootScope.packery == null

        $rootScope.packery = new Packery element[0].parentElement,
          columnWidth: ".grid-sizer"
          itemSelector: ".item"
          gutter: ".gutter-sizer"

        $rootScope.packery.bindResize()
        $rootScope.packery.appended element[0]
        $rootScope.packery.items.splice 1, 1

      else
        $rootScope.packery.appended element[0]

      $rootScope.packery.layout()
  }
]
