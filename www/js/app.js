(function (angular) {
  'use strict';

  ///////////////////////////////////////////////////////////////////////////

  var app = angular.module('JobsWatchApp', [
    'ui.bootstrap',
  ]);

  app.controller('RecentList', function ($scope, $http) {
    $scope.totalCount = 0;
    $scope.pageNumber = 1;
    $scope.recent = [];
    $scope.activeEntry = null;

    $scope.setActive = function (k) {
      $scope.activeEntry = $scope.recent[k];
    };

    $scope.$watch('pageNumber', reloadPage);

    setTimeout(function () {
      setInterval(reloadPage, 3 * 60 * 1000);
    }, 30 * 1000);


    function reloadPage() {
      $http({
        url: '/recent',
        method: 'GET',
        params: {
          page: ($scope.pageNumber - 1)
        },
      }).success(function (data) {
        $scope.totalCount = data.total;

        $scope.recent = data.list;
        $scope.recent.forEach(function (entry) {
          entry.published = Date.create(entry.published);
          entry.discovered = Date.create(entry.discovered);

          if (entry.target.indexOf('freelansim') !== -1) {
            entry.icon = 'http://freelansim.ru/favicon.png';
          }
          if (entry.target.indexOf('elance') !== -1) {
            entry.icon = 'https://www.elance.com/media/images/4.0/favicon.ico';
          }
          if (entry.target.indexOf('peopleperhour') !== -1) {
            entry.icon = 'http://www.peopleperhour.com/favicon2.ico';
          }
        });
      });
    }

  });

}(angular));
