window.HNTab = angular.module "HNTab", []

window.HNTab.filter "truncate", ->
  (text, length, end) ->

    length = 32 if isNaN length
    end = "..." unless end

    if text.length <= length or text.length - end.length < length
      text
    else
      "#{text[0..length - end.length].trim()}#{end}"

window.HNTab.controller "main", ($scope, $http) ->

  $scope.generateBackground = (item) ->
    if item.image
      "url(#{item.image})"
    else
      "#2ecc71"

  $http.get("http://localhost:5656/api/v1/news")
  .success (content) ->
    $scope.content = content
