(function () {
  var el = document.getElementById("transit-dashboard");
  if (!el) return;
  var url = el.getAttribute("data-csv-url");

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
