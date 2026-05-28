//
//  ContentView.swift
//  Sage & Speak
//
//  Created by Emma Wichmann on 5/22/26.
//  Features: affirmations, categories, favorites, streak, week tracker, therapy tab
//  Built with Swift/SwiftUI. Coded with AI assistance (testing + iteration).
//
 
import SwiftUI
 
// MARK: - Data
 
let affirmationData: [(text: String, cat: String)] = [
    ("My voice deserves to be heard.",                    "Confidence"),
    ("I speak with power and purpose.",                   "Confidence"),
    ("I am a confident communicator.",                    "Confidence"),
    ("Every word I speak matters.",                       "Confidence"),
    ("I own every room I walk into.",                     "Confidence"),
    ("I can speak at my own pace.",                       "Fluency"),
    ("I do not need to rush my words.",                   "Fluency"),
    ("Pausing is a sign of thoughtfulness.",              "Fluency"),
    ("My voice flows more freely every day.",             "Fluency"),
    ("Every conversation is a chance to grow.",           "Fluency"),
    ("I am brave enough to use my voice.",                "Courage"),
    ("I choose courage over silence.",                    "Courage"),
    ("I show up fully, voice and all.",                   "Courage"),
    ("Being heard is worth the vulnerability.",           "Courage"),
    ("I face difficult conversations with grace.",        "Courage"),
    ("I am more than my stutter.",                        "Self-Worth"),
    ("My worth is not how smoothly I speak.",             "Self-Worth"),
    ("I deserve to be in every conversation.",            "Self-Worth"),
    ("I am whole, worthy, and enough.",                   "Self-Worth"),
    ("I am proud of how far I have come.",                "Self-Worth"),
    ("I breathe deeply and speak from calm.",             "Calm"),
    ("My breath is my anchor.",                           "Calm"),
    ("I am grounded, steady, and present.",               "Calm"),
    ("I soften my body and let my voice follow.",         "Calm"),
    ("There is no rush. My words will come.",             "Calm"),
]
 
let catEmoji = ["Confidence":"💪","Fluency":"🗣️","Courage":"🌟","Self-Worth":"🌸","Calm":"🍃"]
 
// MARK: - App
 
struct ContentView: View {
 
    // Affirmation state
    @State private var current      = "Tap below to begin 💕"
    @State private var currentCat   = ""
    @State private var filterCat    = "All"
    @State private var dailyCount   = 0
    @State private var allTime      = 0
    @State private var streak       = 0
    @State private var favorites: [String] = []
    @State private var weekDays     = ["M":false,"T":false,"W":false,"Th":false,"F":false,"Sa":false,"Su":false]
 
    // Therapy state
    @State private var weekFocus    = ""
    @State private var sessionNote  = ""
    @State private var mood         = "Good 🙂"
    @State private var sessions: [(mood:String, note:String, date:String)] = []
 
    // Colors
    let rD = Color(red:0.55,green:0.22,blue:0.22)
    let rM = Color(red:0.72,green:0.38,blue:0.38)
    let rS = Color(red:0.88,green:0.54,blue:0.48)
    let rB = Color(red:0.99,green:0.94,blue:0.91)
    let rT = Color(red:0.60,green:0.38,blue:0.34)
    let sD = Color(red:0.22,green:0.38,blue:0.30)
    let sM = Color(red:0.38,green:0.55,blue:0.44)
    let sB = Color(red:0.91,green:0.95,blue:0.92)
    let sT = Color(red:0.40,green:0.52,blue:0.44)
 
    let cats  = ["All","Confidence","Fluency","Courage","Self-Worth","Calm"]
    let moods = ["Great 🌟","Good 🙂","Okay 😐","Hard 😔","Really Hard 💙"]
    let days  = ["M","T","W","Th","F","Sa","Su"]
 
    var body: some View {
        TabView {
            todayTab
                .tabItem { Label("Today",    systemImage:"sun.max.fill") }
            favTab
                .tabItem { Label("Favorites",systemImage:"heart.fill") }
            therapyTab
                .tabItem { Label("Therapy",  systemImage:"leaf.fill") }
            progressTab
                .tabItem { Label("Progress", systemImage:"chart.bar.fill") }
        }
        .accentColor(rM)
    }
 
    // MARK: - Today Tab
    var todayTab: some View {
        ZStack {
            LinearGradient(colors:[rB,Color(red:0.96,green:0.89,blue:0.86)],
                           startPoint:.top,endPoint:.bottom).ignoresSafeArea()
            ScrollView {
                VStack(spacing:20) {
                    // Header
                    VStack(spacing:4) {
                        Text("🌸 Sage & Speak")
                            .font(.custom("Georgia",size:26)).bold()
                            .foregroundColor(rD)
                        Text("Your voice. Your power. Your pace.")
                            .font(.custom("Georgia",size:14))
                            .foregroundColor(rT)
                    }.padding(.top,18)
 
                    // Stats
                    HStack(spacing:10) {
                        pill("🔥","\(streak)","streak")
                        pill("✨","\(dailyCount)","today")
                        pill("🌸","\(allTime)","all time")
                    }.padding(.horizontal)
 
                    // Category chips
                    ScrollView(.horizontal,showsIndicators:false) {
                        HStack(spacing:8) {
                            ForEach(cats,id:\.self) { c in
                                Button { filterCat = c } label: {
                                    HStack(spacing:4) {
                                        if c != "All" { Text(catEmoji[c]!).font(.system(size:12)) }
                                        Text(c).font(.system(size:13,weight:.semibold,design:.rounded))
                                    }
                                    .foregroundColor(filterCat==c ? .white : rM)
                                    .padding(.horizontal,12).padding(.vertical,7)
                                    .background(filterCat==c ? rM : rM.opacity(0.12))
                                    .cornerRadius(20)
                                }
                            }
                        }.padding(.horizontal)
                    }
 
                    // Card
                    ZStack(alignment:.topTrailing) {
                        VStack(spacing:12) {
                            if !currentCat.isEmpty {
                                Text("\(catEmoji[currentCat] ?? "") \(currentCat)")
                                    .font(.system(size:11,weight:.bold,design:.rounded))
                                    .tracking(1.2).foregroundColor(rM)
                                    .padding(.horizontal,12).padding(.vertical,4)
                                    .background(rM.opacity(0.10)).cornerRadius(20)
                            }
                            Text(current)
                                .font(.custom("Georgia",size:22))
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red:0.22,green:0.08,blue:0.06))
                                .lineSpacing(5).padding(.horizontal,8)
                        }
                        .frame(maxWidth:.infinity).padding(28)
                        .background(Color.white.opacity(0.88)).cornerRadius(24)
                        .shadow(color:rM.opacity(0.12),radius:14,y:5)
 
                        Button {
                            if !current.contains("Tap") {
                                if favorites.contains(current) {
                                    favorites.removeAll{$0==current}
                                } else { favorites.append(current) }
                            }
                        } label: {
                            Image(systemName:favorites.contains(current) ? "heart.fill":"heart")
                                .font(.system(size:20))
                                .foregroundColor(favorites.contains(current) ? rM : Color.gray.opacity(0.40))
                                .padding(16)
                        }
                    }.padding(.horizontal)
 
                    // Button
                    Button {
                        let pool = filterCat=="All" ? affirmationData : affirmationData.filter{$0.cat==filterCat}
                        if let pick = pool.randomElement() {
                            current    = pick.text
                            currentCat = pick.cat
                        }
                        dailyCount += 1
                        allTime    += 1
                        if streak == 0 { streak = 1 }
                        let wd  = Calendar.current.component(.weekday,from:Date())
                        let ks  = ["Su","M","T","W","Th","F","Sat"]
                        if wd>=1&&wd<=7 { weekDays[ks[wd-1]] = true }
                    } label: {
                        Text("New Affirmation ✨")
                            .font(.custom("Georgia",size:18)).bold()
                            .foregroundColor(.white).frame(maxWidth:.infinity)
                            .padding(.vertical,16)
                            .background(LinearGradient(colors:[rM,rS],startPoint:.leading,endPoint:.trailing))
                            .cornerRadius(20)
                            .shadow(color:rM.opacity(0.28),radius:8,y:4)
                    }.padding(.horizontal)
 
                    // Week tracker
                    VStack(spacing:8) {
                        Text("This Week")
                            .font(.custom("Georgia",size:13)).bold()
                            .foregroundColor(rT).frame(maxWidth:.infinity,alignment:.leading)
                        HStack(spacing:6) {
                            ForEach(days,id:\.self) { d in
                                VStack(spacing:4) {
                                    Text(d).font(.system(size:11,weight:.semibold)).foregroundColor(rT)
                                    Circle()
                                        .fill(weekDays[d]==true ? rM : Color(red:0.88,green:0.80,blue:0.78))
                                        .frame(width:30,height:30)
                                        .overlay(Text(weekDays[d]==true ? "✓":"")
                                            .font(.system(size:13,weight:.bold)).foregroundColor(.white))
                                }.frame(maxWidth:.infinity)
                            }
                        }
                    }
                    .padding(14).background(Color.white.opacity(0.72)).cornerRadius(14)
                    .padding(.horizontal)
 
                    Button("Reset today") {
                        dailyCount = 0
                        current    = "Tap below to begin 💕"
                        currentCat = ""
                        weekDays   = ["M":false,"T":false,"W":false,"Th":false,"F":false,"Sa":false,"Su":false]
                    }
                    .font(.system(size:13,design:.rounded)).foregroundColor(rT.opacity(0.65))
                    .padding(.bottom,28)
                }
            }
        }
    }
 
    // MARK: - Favorites Tab
    var favTab: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors:[rB,Color(red:0.96,green:0.89,blue:0.86)],
                               startPoint:.top,endPoint:.bottom).ignoresSafeArea()
                if favorites.isEmpty {
                    VStack(spacing:10) {
                        Text("🤍").font(.system(size:52))
                        Text("No favorites yet")
                            .font(.custom("Georgia",size:18)).foregroundColor(rT)
                        Text("Tap the heart on any affirmation to save it here.")
                            .font(.custom("Georgia",size:14)).foregroundColor(rT)
                            .multilineTextAlignment(.center).padding(.horizontal,40)
                    }
                } else {
                    List {
                        ForEach(favorites,id:\.self) { f in
                            HStack {
                                Text("🌸").font(.system(size:20))
                                Text(f).font(.custom("Georgia",size:15))
                                    .foregroundColor(Color(red:0.22,green:0.08,blue:0.06))
                                Spacer()
                                Button { favorites.removeAll{$0==f} } label: {
                                    Image(systemName:"heart.fill").foregroundColor(rM)
                                }
                            }.listRowBackground(Color.white.opacity(0.75))
                        }.onDelete { favorites.remove(atOffsets:$0) }
                    }
                    .listStyle(.insetGrouped).scrollContentBackground(.hidden)
                }
            }.navigationTitle("💗 Favorites")
        }
    }
 
    // MARK: - Therapy Tab
    var therapyTab: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors:[sB,Color(red:0.88,green:0.94,blue:0.90)],
                               startPoint:.top,endPoint:.bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing:18) {
                        VStack(spacing:4) {
                            Text("🍃 Therapy Space")
                                .font(.custom("Georgia",size:22)).bold().foregroundColor(sD)
                            Text("A quiet place to reflect and grow.")
                                .font(.custom("Georgia",size:14)).foregroundColor(sT)
                        }.padding(.top,8)
 
                        // Weekly focus
                        VStack(alignment:.leading,spacing:8) {
                            Text("🎯 This Week's Focus")
                                .font(.custom("Georgia",size:16)).bold().foregroundColor(sD)
                            ZStack(alignment:.topLeading) {
                                if weekFocus.isEmpty {
                                    Text("e.g. Slowing down before I speak...")
                                        .font(.custom("Georgia",size:15))
                                        .foregroundColor(sT.opacity(0.50))
                                        .padding(.top,8).padding(.leading,5)
                                }
                                TextEditor(text:$weekFocus)
                                    .font(.custom("Georgia",size:15))
                                    .foregroundColor(sD).frame(minHeight:80)
                                    .scrollContentBackground(.hidden)
                            }
                            .padding(10).background(Color.white.opacity(0.75)).cornerRadius(12)
                        }
                        .padding(16).background(Color.white.opacity(0.68)).cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius:16).stroke(sM.opacity(0.25),lineWidth:1))
                        .padding(.horizontal)
 
                        // Log session
                        VStack(alignment:.leading,spacing:10) {
                            Text("📝 Log a Session")
                                .font(.custom("Georgia",size:16)).bold().foregroundColor(sD)
 
                            Text("How are you feeling?")
                                .font(.custom("Georgia",size:13)).foregroundColor(sT)
 
                            ScrollView(.horizontal,showsIndicators:false) {
                                HStack(spacing:8) {
                                    ForEach(moods,id:\.self) { m in
                                        Button { mood = m } label: {
                                            Text(m)
                                                .font(.system(size:13,weight:.semibold,design:.rounded))
                                                .foregroundColor(mood==m ? .white : sD)
                                                .padding(.horizontal,12).padding(.vertical,7)
                                                .background(mood==m ? sM : sM.opacity(0.12))
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            }
 
                            Text("Session notes")
                                .font(.custom("Georgia",size:13)).foregroundColor(sT)
 
                            ZStack(alignment:.topLeading) {
                                if sessionNote.isEmpty {
                                    Text("What came up? What did you work on?")
                                        .font(.custom("Georgia",size:15))
                                        .foregroundColor(sT.opacity(0.50))
                                        .padding(.top,8).padding(.leading,5)
                                }
                                TextEditor(text:$sessionNote)
                                    .font(.custom("Georgia",size:15))
                                    .foregroundColor(sD).frame(minHeight:100)
                                    .scrollContentBackground(.hidden).lineSpacing(4)
                            }
                            .padding(10).background(Color.white.opacity(0.75)).cornerRadius(12)
 
                            Button {
                                let f = DateFormatter(); f.dateStyle = .medium
                                sessions.insert((mood:mood,note:sessionNote,date:f.string(from:Date())),at:0)
                                sessionNote = ""
                            } label: {
                                Text("Save Session 🍃")
                                    .font(.custom("Georgia",size:16)).bold()
                                    .foregroundColor(.white).frame(maxWidth:.infinity)
                                    .padding(.vertical,13)
                                    .background(LinearGradient(colors:[sD,sM],startPoint:.leading,endPoint:.trailing))
                                    .cornerRadius(16)
                            }
                        }
                        .padding(16).background(Color.white.opacity(0.68)).cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius:16).stroke(sM.opacity(0.25),lineWidth:1))
                        .padding(.horizontal)
 
                        // Past sessions
                        if !sessions.isEmpty {
                            VStack(alignment:.leading,spacing:10) {
                                Text("Past Sessions")
                                    .font(.custom("Georgia",size:16)).bold().foregroundColor(sD)
                                ForEach(sessions.indices,id:\.self) { i in
                                    VStack(alignment:.leading,spacing:5) {
                                        HStack {
                                            Text(sessions[i].mood)
                                                .font(.system(size:14,weight:.semibold,design:.rounded))
                                                .foregroundColor(sM)
                                            Spacer()
                                            Text(sessions[i].date)
                                                .font(.custom("Georgia",size:12)).foregroundColor(sT)
                                        }
                                        if !sessions[i].note.isEmpty {
                                            Text(sessions[i].note)
                                                .font(.custom("Georgia",size:14))
                                                .foregroundColor(sD).lineSpacing(3)
                                        }
                                    }
                                    .padding(12).background(Color.white.opacity(0.75)).cornerRadius(12)
                                }
                            }
                            .padding(16).background(Color.white.opacity(0.68)).cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius:16).stroke(sM.opacity(0.20),lineWidth:1))
                            .padding(.horizontal)
                        }
                        Spacer(minLength:28)
                    }.padding(.bottom,28)
                }
            }
            .navigationTitle("Therapy Space")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
 
    // MARK: - Progress Tab
    var progressTab: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors:[rB,Color(red:0.96,green:0.89,blue:0.86)],
                               startPoint:.top,endPoint:.bottom).ignoresSafeArea()
                ScrollView {
                    VStack(spacing:16) {
                        VStack(spacing:6) {
                            Text("🔥").font(.system(size:48))
                            Text("\(streak)")
                                .font(.custom("Georgia",size:56)).bold().foregroundColor(rM)
                            Text("day streak")
                                .font(.custom("Georgia",size:16)).foregroundColor(rT)
                        }
                        .frame(maxWidth:.infinity).padding(.vertical,24)
                        .background(Color.white.opacity(0.75)).cornerRadius(20)
                        .padding(.horizontal)
 
                        LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible())],spacing:12) {
                            statCard("🌸","\(allTime)","Total Affirmations")
                            statCard("✨","\(dailyCount)","Today")
                            statCard("💗","\(favorites.count)","Favorited")
                            statCard("🍃","\(sessions.count)","Sessions Logged")
                        }.padding(.horizontal)
 
                        Spacer(minLength:28)
                    }.padding(.top,16)
                }
            }.navigationTitle("📊 My Progress")
        }
    }
 
    // MARK: - Helper Views
    func pill(_ icon:String,_ val:String,_ label:String) -> some View {
        VStack(spacing:3) {
            Text(icon).font(.system(size:15))
            Text(val).font(.custom("Georgia",size:20)).bold().foregroundColor(rD)
            Text(label).font(.system(size:10,design:.rounded)).foregroundColor(rT)
        }
        .frame(maxWidth:.infinity).padding(.vertical,11)
        .background(Color.white.opacity(0.75)).cornerRadius(14)
    }
 
    func statCard(_ icon:String,_ val:String,_ label:String) -> some View {
        VStack(spacing:6) {
            Text(icon).font(.system(size:26))
            Text(val).font(.custom("Georgia",size:28)).bold().foregroundColor(rM)
            Text(label).font(.system(size:12,design:.rounded)).foregroundColor(rT)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth:.infinity).padding(.vertical,18)
        .background(Color.white.opacity(0.75)).cornerRadius(16)
    }
}
 
#Preview {
    ContentView()
}
