window.HNTab = angular.module "HNTab", []
window.HNTab.controller "main", ($scope, $http) ->

  $http.get("http://node-hnapi.herokuapp.com/news")
  .success (content) ->
    $scope.content = content
