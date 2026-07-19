// Sage & Speak, web version
// Mirrors the original SwiftUI app's data and behavior, saved with localStorage
// instead of @AppStorage/UserDefaults.

const affirmationData = [
  ["My voice deserves to be heard.", "Confidence"],
  ["I speak with power and purpose.", "Confidence"],
  ["I am a confident communicator.", "Confidence"],
  ["Every word I speak matters.", "Confidence"],
  ["I own every room I walk into.", "Confidence"],
  ["I can speak at my own pace.", "Fluency"],
  ["I do not need to rush my words.", "Fluency"],
  ["Pausing is a sign of thoughtfulness.", "Fluency"],
  ["My voice flows more freely every day.", "Fluency"],
  ["Every conversation is a chance to grow.", "Fluency"],
  ["I am brave enough to use my voice.", "Courage"],
  ["I choose courage over silence.", "Courage"],
  ["I show up fully, voice and all.", "Courage"],
  ["Being heard is worth the vulnerability.", "Courage"],
  ["I face difficult conversations with grace.", "Courage"],
  ["I am more than my stutter.", "Self-Worth"],
  ["My worth is not how smoothly I speak.", "Self-Worth"],
  ["I deserve to be in every conversation.", "Self-Worth"],
  ["I am whole, worthy, and enough.", "Self-Worth"],
  ["I am proud of how far I have come.", "Self-Worth"],
  ["I breathe deeply and speak from calm.", "Calm"],
  ["My breath is my anchor.", "Calm"],
  ["I am grounded, steady, and present.", "Calm"],
  ["I soften my body and let my voice follow.", "Calm"],
  ["There is no rush. My words will come.", "Calm"],
];

const catEmoji = { "Confidence": "💪", "Fluency": "🗣️", "Courage": "🌟", "Self-Worth": "🌸", "Calm": "🍃" };
const cats = ["All", "Confidence", "Fluency", "Courage", "Self-Worth", "Calm"];
const moods = ["Great 🌟", "Good 🙂", "Okay 😐", "Hard 😔", "Really Hard 💙"];
const dayKeys = ["M", "T", "W", "Th", "F", "Sa", "Su"];
const dayFromJsWeekday = ["Su", "M", "T", "W", "Th", "F", "Sa"]; // JS getDay(): 0=Sun

// ---- state, loaded from localStorage ----
function load(key, fallback) {
  try {
    const v = localStorage.getItem(key);
    return v === null ? fallback : JSON.parse(v);
  } catch { return fallback; }
}
function save(key, val) { localStorage.setItem(key, JSON.stringify(val)); }

let state = {
  dailyCount: load("dailyCount", 0),
  allTime: load("allTime", 0),
  streak: load("streak", 0),
  favorites: load("favorites", []),
  weekDays: load("weekDays", { M: false, T: false, W: false, Th: false, F: false, Sa: false, Su: false }),
  weekFocus: load("weekFocus", ""),
  sessions: load("sessions", []), // {mood, note, date}
  current: load("current", ""),
  currentCat: load("currentCat", ""),
};

let filterCat = "All";
let selectedMood = moods[1];

// ---- element refs ----
const el = (id) => document.getElementById(id);
const affirmationText = el("affirmationText");
const catTag = el("catTag");
const heartBtn = el("heartBtn");
const chipRow = el("chipRow");
const moodRow = el("moodRow");
const weekRow = el("weekRow");

// ---- render helpers ----
function renderStats() {
  el("streakVal").textContent = state.streak;
  el("dailyVal").textContent = state.dailyCount;
  el("allTimeVal").textContent = state.allTime;
  el("progressStreak").textContent = state.streak;
  el("statAllTime").textContent = state.allTime;
  el("statToday").textContent = state.dailyCount;
  el("statFav").textContent = state.favorites.length;
  el("statSessions").textContent = state.sessions.length;
}

function renderChips() {
  chipRow.innerHTML = "";
  cats.forEach((c) => {
    const btn = document.createElement("button");
    btn.className = "chip" + (filterCat === c ? " active" : "");
    btn.textContent = (c !== "All" ? catEmoji[c] + " " : "") + c;
    btn.addEventListener("click", () => { filterCat = c; renderChips(); });
    chipRow.appendChild(btn);
  });
}

function renderMoodChips() {
  moodRow.innerHTML = "";
  moods.forEach((m) => {
    const btn = document.createElement("button");
    btn.className = "chip mood-chip" + (selectedMood === m ? " active" : "");
    btn.textContent = m;
    btn.addEventListener("click", () => { selectedMood = m; renderMoodChips(); });
    moodRow.appendChild(btn);
  });
}

function renderAffirmation() {
  if (!state.current) {
    affirmationText.textContent = "Tap below to begin 💕";
    catTag.hidden = true;
  } else {
    affirmationText.textContent = state.current;
    if (state.currentCat) {
      catTag.hidden = false;
      catTag.textContent = (catEmoji[state.currentCat] || "") + " " + state.currentCat;
    } else {
      catTag.hidden = true;
    }
  }
  const isFav = state.favorites.includes(state.current) && state.current !== "";
  heartBtn.classList.toggle("active", isFav);
}

function renderWeek() {
  weekRow.innerHTML = "";
  dayKeys.forEach((d) => {
    const col = document.createElement("div");
    col.className = "day-col";
    const done = !!state.weekDays[d];
    col.innerHTML = `<span class="day-name">${d}</span><span class="day-dot${done ? " done" : ""}">${done ? "✓" : ""}</span>`;
    weekRow.appendChild(col);
  });
}

function renderFavorites() {
  const list = el("favList");
  const empty = el("favEmpty");
  list.innerHTML = "";
  if (state.favorites.length === 0) {
    empty.style.display = "block";
    list.style.display = "none";
    return;
  }
  empty.style.display = "none";
  list.style.display = "flex";
  state.favorites.forEach((f) => {
    const li = document.createElement("li");
    li.className = "fav-item";
    li.innerHTML = `<span>🌸</span><span class="fav-text">${escapeHtml(f)}</span>`;
    const removeBtn = document.createElement("button");
    removeBtn.className = "fav-remove";
    removeBtn.innerHTML = "♥";
    removeBtn.addEventListener("click", () => {
      state.favorites = state.favorites.filter((x) => x !== f);
      save("favorites", state.favorites);
      renderFavorites(); renderAffirmation(); renderStats();
    });
    li.appendChild(removeBtn);
    list.appendChild(li);
  });
}

function renderSessions() {
  const card = el("pastSessionsCard");
  const wrap = el("sessionsList");
  wrap.innerHTML = "";
  if (state.sessions.length === 0) { card.hidden = true; return; }
  card.hidden = false;
  state.sessions.forEach((s) => {
    const div = document.createElement("div");
    div.className = "session-entry";
    div.innerHTML = `
      <div class="session-top"><span>${escapeHtml(s.mood)}</span><span class="session-date">${escapeHtml(s.date)}</span></div>
      ${s.note ? `<p class="session-note">${escapeHtml(s.note)}</p>` : ""}
    `;
    wrap.appendChild(div);
  });
}

function escapeHtml(str) {
  const d = document.createElement("div");
  d.textContent = str;
  return d.innerHTML;
}

// ---- actions ----
function newAffirmation() {
  const pool = filterCat === "All" ? affirmationData : affirmationData.filter((a) => a[1] === filterCat);
  const pick = pool[Math.floor(Math.random() * pool.length)];
  state.current = pick[0];
  state.currentCat = pick[1];
  state.dailyCount += 1;
  state.allTime += 1;
  if (state.streak === 0) state.streak = 1;
  const key = dayFromJsWeekday[new Date().getDay()];
  state.weekDays[key] = true;

  save("current", state.current);
  save("currentCat", state.currentCat);
  save("dailyCount", state.dailyCount);
  save("allTime", state.allTime);
  save("streak", state.streak);
  save("weekDays", state.weekDays);

  renderAffirmation(); renderStats(); renderWeek();
}

function toggleHeart() {
  if (!state.current) return;
  if (state.favorites.includes(state.current)) {
    state.favorites = state.favorites.filter((x) => x !== state.current);
  } else {
    state.favorites.push(state.current);
  }
  save("favorites", state.favorites);
  renderAffirmation(); renderFavorites(); renderStats();
}

function resetToday() {
  state.dailyCount = 0;
  state.current = "";
  state.currentCat = "";
  state.weekDays = { M: false, T: false, W: false, Th: false, F: false, Sa: false, Su: false };
  save("dailyCount", 0); save("current", ""); save("currentCat", ""); save("weekDays", state.weekDays);
  renderAffirmation(); renderStats(); renderWeek();
}

function saveSession() {
  const note = el("sessionNote").value.trim();
  const date = new Date().toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
  state.sessions.unshift({ mood: selectedMood, note, date });
  save("sessions", state.sessions);
  el("sessionNote").value = "";
  renderSessions(); renderStats();
}

// ---- tab switching ----
function initTabs() {
  const panels = document.querySelectorAll(".tab-panel");
  const buttons = document.querySelectorAll(".tab-btn");
  buttons.forEach((btn) => {
    btn.addEventListener("click", () => {
      const target = btn.dataset.tab;
      panels.forEach((p) => p.classList.toggle("active", p.dataset.panel === target));
      buttons.forEach((b) => b.classList.toggle("active", b === btn));
    });
  });
}

// ---- status bar clock ----
function updateClock() {
  const clockEl = el("statusTime");
  if (!clockEl) return;
  const now = new Date();
  let h = now.getHours();
  const m = now.getMinutes();
  h = h % 12; if (h === 0) h = 12;
  clockEl.textContent = h + ":" + String(m).padStart(2, "0");
}

// ---- wire up ----
function init() {
  updateClock();
  setInterval(updateClock, 15000);
  initTabs();
  renderChips();
  renderMoodChips();
  renderAffirmation();
  renderStats();
  renderWeek();
  renderFavorites();
  renderSessions();

  el("weekFocus").value = state.weekFocus;
  el("weekFocus").addEventListener("input", (e) => { state.weekFocus = e.target.value; save("weekFocus", state.weekFocus); });

  el("newAffirmationBtn").addEventListener("click", newAffirmation);
  heartBtn.addEventListener("click", toggleHeart);
  el("resetTodayBtn").addEventListener("click", resetToday);
  el("saveSessionBtn").addEventListener("click", saveSession);
}

init();
