---
layout: single
title: Brett Takes Transit
permalink: /transit/
---

I've recently become obsessed with public (or quasi-public) transit.
I've been watching a lot of YouTube videos about transit from
  creators like [Miles in Transit](https://www.youtube.com/c/milesintransit)
  and [CityNerd](https://www.youtube.com/c/citynerd).
I love talking about transit,
  especially about Amtrak and bus networks.
I'm somewhat new to the space,
  but I'm eager to learn more from people!

Fortunately,
  I currently live in Seattle which has fairly extensive public transit
  (by American standards).
I'm attempting to ride every bus route
  run by either King County Metro or Sound Transit
  within King County.
I just need to ride it at least one stop,
  not necessarily ride the entire route from start to finish.
Track my progress below!

## Progress

<div id="transit-dashboard" data-csv-url="https://docs.google.com/spreadsheets/d/e/2PACX-1vQWYIkcvbhjtEPvPcIHm4tUfHbv3gPWoFMlcKKwSm_2fFoOYmlzK7sWBcYjl4R1qreFfk9TaD3zCyAB/pub?gid=1062371871&single=true&output=csv">
  <p>Loading progress…</p>
</div>

<style>
#transit-dashboard table { width: 100%; }
#transit-dashboard .bar {
  position: relative;
  background: #e8e8e8;
  border-radius: 4px;
  height: 1.1em;
  min-width: 80px;
  overflow: hidden;
}
#transit-dashboard .bar > span {
  display: block;
  height: 100%;
  background: #4a8;
  border-radius: 4px;
}
#transit-dashboard .bar > em {
  position: absolute;
  top: 0; left: 0; right: 0;
  text-align: center;
  font-style: normal;
  font-size: 0.8em;
  line-height: 1.1em;
}
#transit-dashboard td.num { text-align: right; }
</style>

<script>
(function () {
  var el = document.getElementById("transit-dashboard");
  var url = el.getAttribute("data-csv-url");

  // Minimal CSV parser: handles quoted fields and embedded commas/quotes.
  function parseCSV(text) {
    var rows = [], row = [], field = "", inQuotes = false;
    for (var i = 0; i < text.length; i++) {
      var c = text[i];
      if (inQuotes) {
        if (c === '"') {
          if (text[i + 1] === '"') { field += '"'; i++; }
          else { inQuotes = false; }
        } else { field += c; }
      } else if (c === '"') {
        inQuotes = true;
      } else if (c === ",") {
        row.push(field); field = "";
      } else if (c === "\n" || c === "\r") {
        if (c === "\r" && text[i + 1] === "\n") i++;
        row.push(field); field = "";
        if (row.length > 1 || row[0] !== "") rows.push(row);
        row = [];
      } else { field += c; }
    }
    if (field !== "" || row.length) { row.push(field); rows.push(row); }
    return rows;
  }

  function escapeHTML(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }

  function render(rows) {
    if (!rows.length) { el.innerHTML = "<p>No progress data available.</p>"; return; }
    var header = rows[0];
    var html = "<table><thead><tr>";
    header.forEach(function (h, i) {
      html += "<th>" + escapeHTML(i === 0 ? "Category" : h) + "</th>";
    });
    html += "</tr></thead><tbody>";

    rows.slice(1).forEach(function (r) {
      html += "<tr>";
      html += "<td>" + escapeHTML(r[0]) + "</td>";
      html += "<td class='num'>" + escapeHTML(r[1]) + "</td>";
      html += "<td class='num'>" + escapeHTML(r[2]) + "</td>";
      var pct = parseFloat(r[3]);
      var w = isNaN(pct) ? 0 : Math.max(0, Math.min(100, pct));
      html += "<td><div class='bar'><span style='width:" + w + "%'></span>" +
              "<em>" + escapeHTML(r[3] || "") + "</em></div></td>";
      html += "</tr>";
    });

    html += "</tbody></table>";
    el.innerHTML = html;
  }

  fetch(url)
    .then(function (resp) {
      if (!resp.ok) throw new Error("HTTP " + resp.status);
      return resp.text();
    })
    .then(function (text) { render(parseCSV(text)); })
    .catch(function (err) {
      el.innerHTML = "<p>Couldn't load progress data (" + escapeHTML(err.message) + ").</p>";
    });
})();
</script>

