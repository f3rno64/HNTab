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

  colors = [
    "#2ecc71"
    "#3498db"
    "#9b59b6"
    "#f1c40f"
    "#e67e22"
    "#e74c3c"
  ]

  $scope.generateBackground = (item) ->
    if item.image
      "url(#{item.image})"
    else
      colors[Math.floor(Math.random() * colors.length)]

  $scope.open = (url) ->
    window.location = url

  $scope.goApps = ->
    _gaq.push ["_trackEvent", "Meta", "Back to Apps"]
    chrome.tabs.update url: "chrome://apps"

  $http.get("http://localhost:5656/api/v1/news")
  .success (content) ->
    $scope.content = content
