// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

class Spot {
  constructor(name, lat, lon) {
    this.name = name;
    this.lat = lat;
    this.lon = lon;
  }
}

// Replace with API call eventually
temp_spots = [
  new Spot('spot1', 45.5051, -122.6750),
  new Spot('spot2', 60, -50),
  new Spot('spot3', 80, 150),
  new Spot('spot4', -50, 150)
]

// World map - wildcard!
// Replace temp_spots with api call!
function initBigMap() {

  test_spot = temp_spots[0];

  var myCoords = new google.maps.LatLng(test_spot.lat, test_spot.lon);
  var mapOptions = {
    center: myCoords,
    zoom: 14
  };

  var map = new google.maps.Map(document.getElementById('bigMap'), mapOptions);

  let spots = temp_spots

  spots.forEach(function(spot) {
    coords = new google.maps.LatLng(spot.lat, spot.lon);
    var marker = new google.maps.Marker({
      position: coords,
      map: map,
      // label: spot.name,
      title: spot.name
    });
    var contentString = `<div id="content"><h3>${spot.name}</h3><a href="https://en.wikipedia.org/wiki/Golden_Gate_Bridge">${spot.name} Link</a></p></div>`;
    var infowindow = new google.maps.InfoWindow({
      content: contentString
    });
    marker.addListener('click', function() {
      infowindow.open(map, marker);
    });
  });
}



// If troubles: consider trying lng vs lon
// Show individual map
function initMap(lat, lon) {
  var myCoords = new google.maps.LatLng(lat, lon);
  var mapOptions = {
    center: myCoords,
    zoom: 14
  };
  var map = new google.maps.Map(document.getElementById('map'), mapOptions);

  var marker = new google.maps.Marker({
    position: myCoords,
    map: map
  });
}


// Edit individual marker / map
function initMap2() {
    var lat = document.getElementById('place_lat').value;
    var lng = document.getElementById('place_lon').value;

    // if not defined create default position
    if (!lat || !lng){
        lat=51.5;
        lng=-0.125;
        document.getElementById('place_lat').value = lat;
        document.getElementById('place_lon').value = lng;
    }
    var myCoords = new google.maps.LatLng(lat, lng);
    var mapOptions = {
    center: myCoords,
    zoom: 14
    };
    var map = new google.maps.Map(document.getElementById('map2'), mapOptions);
    var marker = new google.maps.Marker({
        position: myCoords,
        animation: google.maps.Animation.DROP,
        map: map,
        draggable: true
    });
    // refresh marker position and recenter map on marker
    function refreshMarker(){
        var lat = document.getElementById('place_lat').value;
        var lng = document.getElementById('place_lon').value;
        var myCoords = new google.maps.LatLng(lat, lng);
        marker.setPosition(myCoords);
        map.setCenter(marker.getPosition());
    }
    // when input values change call refreshMarker
    document.getElementById('place_lat').onchange = refreshMarker;
    document.getElementById('place_lon').onchange = refreshMarker;
    // when marker is dragged update input values
    marker.addListener('drag', function() {
        latlng = marker.getPosition();
        newlat=(Math.round(latlng.lat()*1000000))/1000000;
        newlng=(Math.round(latlng.lng()*1000000))/1000000;
        document.getElementById('place_lat').value = newlat;
        document.getElementById('place_lon').value = newlng;
    });
    // When drag ends, center (pan) the map on the marker position
    marker.addListener('dragend', function() {
        map.panTo(marker.getPosition());
    });
}

// https://medium.com/@pjbelo/using-google-maps-api-v3-with-rails-5-2-b066a4b2cf14