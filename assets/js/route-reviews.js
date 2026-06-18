(function () {
  var el = document.getElementById("transit-route-reviews");
  if (!el) return;
  var url = el.getAttribute("data-csv-url");
  var PAGE_SIZE = parseInt(el.getAttribute("data-page-size"), 10) || 15;

  var routes = [];   // sorted route labels (one entry per route)
  var groups = {};   // route label -> [{date, note}, ...]
  var currentPage = 1;

  // Map header names to column indices so column order can change safely.
  function indexHeaders(header) {
    var idx = {};
    header.forEach(function (h, i) { idx[h.trim().toLowerCase()] = i; });
    return idx;
  }

  // Sort key for route labels: leading number ascending, lettered routes last.
  function routeSortKey(label) {
    var m = String(label).match(/^\s*(\d+)/);
    return m ? parseInt(m[1], 10) : Infinity;
  }

  // Parse M/D/YY (2-digit year assumed 2000s) into a sortable timestamp.
  // Anything that isn't a concrete date (e.g. "undated") sorts as oldest.
  function parseDate(s) {
    var p = String(s).split("/");
    if (p.length !== 3) return -Infinity;
    var mo = parseInt(p[0], 10), d = parseInt(p[1], 10), y = parseInt(p[2], 10);
    if (isNaN(mo) || isNaN(d) || isNaN(y)) return -Infinity;
    if (y < 100) y += 2000;
    return new Date(y, mo - 1, d).getTime();
  }

  // Build the list of page numbers to show, with "…" gaps for large counts.
  function pageList(current, total) {
    var delta = 2, pages = [], withDots = [], prev;
    for (var i = 1; i <= total; i++) {
      if (i === 1 || i === total || (i >= current - delta && i <= current + delta)) {
        pages.push(i);
      }
    }
    pages.forEach(function (i) {
      if (prev) {
        if (i - prev === 2) withDots.push(prev + 1);
        else if (i - prev !== 1) withDots.push("...");
      }
      withDots.push(i);
      prev = i;
    });
    return withDots;
  }

  function pagerHTML(current, total) {
    if (total <= 1) return "";
    var html = "<nav class='pager' aria-label='Route review pages'>";
    html += "<button data-page='1'" +
            (current === 1 ? " disabled" : "") + " aria-label='First page'>«</button>";
    html += "<button data-page='" + (current - 1) + "'" +
            (current === 1 ? " disabled" : "") + " aria-label='Previous page'>‹</button>";
    pageList(current, total).forEach(function (p) {
      if (p === "...") {
        html += "<span class='ellipsis'>…</span>";
      } else {
        html += "<button data-page='" + p + "'" +
                (p === current ? " class='current' aria-current='page'" : "") +
                ">" + p + "</button>";
      }
    });
    html += "<button data-page='" + (current + 1) + "'" +
            (current === total ? " disabled" : "") + " aria-label='Next page'>›</button>";
    html += "<button data-page='" + total + "'" +
            (current === total ? " disabled" : "") + " aria-label='Last page'>»</button>";
    html += "</nav>";
    return html;
  }

  function renderPage(page) {
    var total = Math.ceil(routes.length / PAGE_SIZE);
    currentPage = Math.max(1, Math.min(page, total));
    var start = (currentPage - 1) * PAGE_SIZE;
    var slice = routes.slice(start, start + PAGE_SIZE);

    var html = "";
    slice.forEach(function (num) {
      var reviews = groups[num].slice().sort(function (a, b) {
        // newest first; compare (not subtract) so -Infinity ties don't yield NaN
        var ta = parseDate(a.date), tb = parseDate(b.date);
        return ta === tb ? 0 : (tb > ta ? 1 : -1);
      });
      html += "<details class='route-review'>";
      html += "<summary>" + escapeHTML(num) + "</summary>";
      html += "<div class='reviews'>";
      reviews.forEach(function (rev) {
        var label = rev.date.charAt(0).toUpperCase() + rev.date.slice(1);
        html += "<p><strong>" + escapeHTML(label) + ".</strong> " +
                escapeHTML(rev.note) + "</p>";
      });
      html += "</div></details>";
    });

    if (routes.length > PAGE_SIZE) {
      html += pagerHTML(currentPage, total);
      html += "<p class='pager-info'>Routes " + (start + 1) + "–" +
              (start + slice.length) + " of " + routes.length + "</p>";
    }
    el.innerHTML = html;
  }

  function build(rows) {
    if (rows.length < 2) { el.innerHTML = "<p>No route reviews yet.</p>"; return; }

    var idx = indexHeaders(rows[0]);
    var cNum = idx["route number"], cDate = idx["date"], cNotes = idx["notes"];
    if (cNum == null || cNotes == null) {
      el.innerHTML = "<p>Couldn't find the expected columns in the data.</p>";
      return;
    }

    groups = {};
    rows.slice(1).forEach(function (r) {
      var note = (r[cNotes] || "").trim();
      if (!note) return;
      var num = (r[cNum] || "").trim();
      if (!num) return;
      (groups[num] = groups[num] || []).push({ date: (r[cDate] || "").trim(), note: note });
    });

    routes = Object.keys(groups);
    if (!routes.length) { el.innerHTML = "<p>No route reviews yet.</p>"; return; }

    routes.sort(function (a, b) {
      var ka = routeSortKey(a), kb = routeSortKey(b);
      if (ka !== kb) return ka - kb;
      return a.localeCompare(b);
    });

    // One delegated handler survives re-renders since el itself isn't replaced.
    el.addEventListener("click", function (e) {
      var btn = e.target.closest("[data-page]");
      if (!btn || btn.disabled) return;
      renderPage(parseInt(btn.getAttribute("data-page"), 10));
      el.scrollIntoView({ behavior: "smooth", block: "start" });
    });

    renderPage(1);
  }

  fetch(url)
    .then(function (resp) {
      if (!resp.ok) throw new Error("HTTP " + resp.status);
      return resp.text();
    })
    .then(function (text) { build(parseCSV(text)); })
    .catch(function (err) {
      el.innerHTML = "<p>Couldn't load route reviews (" + escapeHTML(err.message) + ").</p>";
    });
})();
