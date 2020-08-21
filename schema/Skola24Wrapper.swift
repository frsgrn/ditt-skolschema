//
//  Skola24Wrapper.swift
//  schema
//
//  Created by Victor Forsgren on 2020-07-12.
//  Copyright © 2020 Victor Forsgren. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Domain {
    let name: String
    let url: String
    let id: UUID = UUID()
}

struct s24_Class {
    let id = UUID()
    let name: String
    let groupGuid: String
}

struct Teacher {
    let uuid = UUID()
    let firstName: String
    let lastName: String
    let id: String
    let personGuid: String
}

struct School {
    let id: UUID = UUID()
    let unitGuid: String
    let unitId: String
    let hostName: String
}

struct Selection {
    let teacher: Teacher? = nil
    let s24_class: s24_Class? = nil
    let signature: String? = nil
}

struct Event : Identifiable {
    let id = UUID()
    var start: Date
    var hasStart = false
    var end: Date
    var hasEnd = false
    var title: String
    var information: String
    var x: Int = -1
    var y: Int = -1
    var width: Int = -1
    var height: Int = -1
    
    static func getHourMinuteString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct Timeframe {
    let start: Date
    let end: Date
    let dayOfWeek: Int
    static func formatDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T00:00:00'"
        let dateString = formatter.string(from: date)
        return dateString
    }
}

class Skola24Wrapper{
    
    static var domainList: [Domain] = [
        Domain(name: "4ansgymnasium", url: "4ansgymnasium.skola24.se"),
        Domain(name: "Abf", url: "abf.skola24.se"),
        Domain(name: "Abfsthlm", url: "abfsthlm.skola24.se"),
        Domain(name: "Academediaeductus", url: "academediaeductus.skola24.se"),
        Domain(name: "Agape", url: "agape.skola24.se"),
        Domain(name: "Agestafhsk", url: "agestafhsk.skola24.se"),
        Domain(name: "Ahlaforsfriaskola", url: "ahlaforsfriaskola.skola24.se"),
        Domain(name: "Akademiskaskolan", url: "akademiskaskolan.skola24.se"),
        Domain(name: "Alazharskolan", url: "alazharskolan.skola24.se"),
        Domain(name: "Alazharskolanorebro", url: "alazharskolanorebro.skola24.se"),
        Domain(name: "Ale", url: "ale.skola24.se"),
        Domain(name: "Aleutbildning", url: "aleutbildning.skola24.se"),
        Domain(name: "Algebraskolan", url: "algebraskolan.skola24.se"),
        Domain(name: "Alingsas", url: "alingsas.skola24.se"),
        Domain(name: "Alingsas-sso", url: "alingsas-sso.skola24.se"),
        Domain(name: "Alingsasyrkesgymnasium", url: "alingsasyrkesgymnasium.skola24.se"),
        Domain(name: "Almhult", url: "almhult.skola24.se"),
        Domain(name: "Alsalam", url: "alsalam.skola24.se"),
        Domain(name: "Alt", url: "alt.skola24.se"),
        Domain(name: "Alvdalensutbildningscentrum", url: "alvdalensutbildningscentrum.skola24.se"),
        Domain(name: "Alvesta", url: "alvesta.skola24.se"),
        Domain(name: "Alvsbyn", url: "alvsbyn.skola24.se"),
        Domain(name: "Amal", url: "amal.skola24.se"),
        Domain(name: "Amb", url: "amb.skola24.se"),
        Domain(name: "Aneby", url: "aneby.skola24.se"),
        Domain(name: "Angdala", url: "angdala.skola24.se"),
        Domain(name: "Ange", url: "ange.skola24.se"),
        Domain(name: "Angelholm", url: "angelholm.skola24.se"),
        Domain(name: "Angkarr", url: "angkarr.skola24.se"),
        Domain(name: "Angsdalsskola", url: "angsdalsskola.skola24.se"),
        Domain(name: "Aniaragymnasiet", url: "aniaragymnasiet.skola24.se"),
        Domain(name: "Antonskolan", url: "antonskolan.skola24.se"),
        Domain(name: "Apelrydskolan", url: "apelrydskolan.skola24.se"),
        Domain(name: "Appskolan", url: "appskolan.skola24.se"),
        Domain(name: "Aprendere", url: "aprendere.skola24.se"),
        Domain(name: "Arboga", url: "arboga.skola24.se"),
        Domain(name: "Are", url: "are.skola24.se"),
        Domain(name: "Arjang", url: "arjang.skola24.se"),
        Domain(name: "Arvika", url: "arvika.skola24.se"),
        Domain(name: "Asken", url: "asken.skola24.se"),
        Domain(name: "Askersund", url: "askersund.skola24.se"),
        Domain(name: "Aspero", url: "aspero.skola24.se"),
        Domain(name: "Assaredsskolan", url: "assaredsskolan.skola24.se"),
        Domain(name: "Astorp", url: "astorp.skola24.se"),
        Domain(name: "Atletica", url: "atletica.skola24.se"),
        Domain(name: "Atvidaberg", url: "atvidaberg.skola24.se"),
        Domain(name: "Avesta", url: "avesta.skola24.se"),
        Domain(name: "Backaskolan", url: "backaskolan.skola24.se"),
        Domain(name: "Backatorpsskolan", url: "backatorpsskolan.skola24.se"),
        Domain(name: "Banerportsskolan", url: "banerportsskolan.skola24.se"),
        Domain(name: "Bastad", url: "bastad.skola24.se"),
        Domain(name: "Bastad-foralder", url: "bastad-foralder.skola24.se"),
        Domain(name: "Bengtsfors", url: "bengtsfors.skola24.se"),
        Domain(name: "Berg", url: "berg.skola24.se"),
        Domain(name: "Berganaturbruk", url: "berganaturbruk.skola24.se"),
        Domain(name: "Betel", url: "betel.skola24.se"),
        Domain(name: "Bfg", url: "bfg.skola24.se"),
        Domain(name: "Billstromska", url: "billstromska.skola24.se"),
        Domain(name: "Birkagardenfhsk", url: "birkagardenfhsk.skola24.se"),
        Domain(name: "Birkaskolan", url: "birkaskolan.skola24.se"),
        Domain(name: "Bjorkenasskolan", url: "bjorkenasskolan.skola24.se"),
        Domain(name: "Bjorkofriskola", url: "bjorkofriskola.skola24.se"),
        Domain(name: "Bjurholm", url: "bjurholm.skola24.se"),
        Domain(name: "Bjuv", url: "bjuv.skola24.se"),
        Domain(name: "Bladins", url: "bladins.skola24.se"),
        Domain(name: "Bolebyskola", url: "bolebyskola.skola24.se"),
        Domain(name: "Bollebygd", url: "bollebygd.skola24.se"),
        Domain(name: "Bollerup", url: "bollerup.skola24.se"),
        Domain(name: "Bollnas", url: "bollnas.skola24.se"),
        Domain(name: "Boras", url: "boras.skola24.se"),
        Domain(name: "Borgholm", url: "borgholm.skola24.se"),
        Domain(name: "Borlange", url: "borlange.skola24.se"),
        Domain(name: "Borlange-sso", url: "borlange-sso.skola24.se"),
        Domain(name: "Boskolan", url: "boskolan.skola24.se"),
        Domain(name: "Boson", url: "boson.skola24.se"),
        Domain(name: "Botkyrka", url: "botkyrka.skola24.se"),
        Domain(name: "Botkyrkafriskola", url: "botkyrkafriskola.skola24.se"),
        Domain(name: "Boxholm", url: "boxholm.skola24.se"),
        Domain(name: "Brandstromska", url: "brandstromska.skola24.se"),
        Domain(name: "Britishschools", url: "britishschools.skola24.se"),
        Domain(name: "Bromolla", url: "bromolla.skola24.se"),
        Domain(name: "Burlov", url: "burlov.skola24.se"),
        Domain(name: "Carlssonsskola", url: "carlssonsskola.skola24.se"),
        Domain(name: "Centrina", url: "centrina.skola24.se"),
        Domain(name: "Christinaskolan", url: "christinaskolan.skola24.se"),
        Domain(name: "Cis", url: "cis.skola24.se"),
        Domain(name: "Citygymnasiet", url: "citygymnasiet.skola24.se"),
        Domain(name: "Cordobainternational", url: "cordobainternational.skola24.se"),
        Domain(name: "Cuben", url: "cuben.skola24.se"),
        Domain(name: "Cybergymnasiet", url: "cybergymnasiet.skola24.se"),
        Domain(name: "Dalsed", url: "dalsed.skola24.se"),
        Domain(name: "Dammsdal", url: "dammsdal.skola24.se"),
        Domain(name: "Danderyd", url: "danderyd.skola24.se"),
        Domain(name: "Dansomusikal", url: "dansomusikal.skola24.se"),
        Domain(name: "Degerfors", url: "degerfors.skola24.se"),
        Domain(name: "Demo", url: "demo.skola24.se"),
        Domain(name: "Designgymnasiet", url: "designgymnasiet.skola24.se"),
        Domain(name: "Dibber", url: "dibber.skola24.se"),
        Domain(name: "Didaktus", url: "didaktus.skola24.se"),
        Domain(name: "Distra", url: "distra.skola24.se"),
        Domain(name: "Djurgardenswaldorf", url: "djurgardenswaldorf.skola24.se"),
        Domain(name: "Djurgymnasiet", url: "djurgymnasiet.skola24.se"),
        Domain(name: "Donnergymnasiet", url: "donnergymnasiet.skola24.se"),
        Domain(name: "Dorotea", url: "dorotea.skola24.se"),
        Domain(name: "Drottningblankasgy", url: "drottningblankasgy.skola24.se"),
        Domain(name: "Drottningholmskolan", url: "drottningholmskolan.skola24.se"),
        Domain(name: "Ebbabraheskolan", url: "ebbabraheskolan.skola24.se"),
        Domain(name: "Ebbapettersson", url: "ebbapettersson.skola24.se"),
        Domain(name: "Eda", url: "eda.skola24.se"),
        Domain(name: "Eductus", url: "eductus.skola24.se"),
        Domain(name: "Einarhansengymnasiet", url: "einarhansengymnasiet.skola24.se"),
        Domain(name: "Ekero", url: "ekero.skola24.se"),
        Domain(name: "Eks", url: "eks.skola24.se"),
        Domain(name: "Eksjo", url: "eksjo.skola24.se"),
        Domain(name: "Eksjokommun", url: "eksjokommun.skola24.se"),
        Domain(name: "Elajo", url: "elajo.skola24.se"),
        Domain(name: "Ellenkeyskolan", url: "ellenkeyskolan.skola24.se"),
        Domain(name: "Emmaboda", url: "emmaboda.skola24.se"),
        Domain(name: "Enkoping", url: "enkoping.skola24.se"),
        Domain(name: "Enp", url: "enp.skola24.se"),
        Domain(name: "Enskedebyskola", url: "enskedebyskola.skola24.se"),
        Domain(name: "Enskildagymnasiet", url: "enskildagymnasiet.skola24.se"),
        Domain(name: "Erk", url: "erk.skola24.se"),
        Domain(name: "Escandinavo", url: "escandinavo.skola24.se"),
        Domain(name: "Eskilstuna", url: "eskilstuna.skola24.se"),
        Domain(name: "Eslov", url: "eslov.skola24.se"),
        Domain(name: "Eslovsfhsk", url: "eslovsfhsk.skola24.se"),
        Domain(name: "Esn", url: "esn.skola24.se"),
        Domain(name: "Essunga", url: "essunga.skola24.se"),
        Domain(name: "Estetiskaskolan", url: "estetiskaskolan.skola24.se"),
        Domain(name: "Estniskaskolan", url: "estniskaskolan.skola24.se"),
        Domain(name: "Europaporten", url: "europaporten.skola24.se"),
        Domain(name: "Europaskolan", url: "europaskolan.skola24.se"),
        Domain(name: "Falkenberg", url: "falkenberg.skola24.se"),
        Domain(name: "Falkenberg-sso", url: "falkenberg-sso.skola24.se"),
        Domain(name: "Falkenberg-ssotest", url: "falkenberg-ssotest.skola24.se"),
        Domain(name: "Falkoping", url: "falkoping.skola24.se"),
        Domain(name: "Falufrigymnasium", url: "falufrigymnasium.skola24.se"),
        Domain(name: "Falun", url: "falun.skola24.se"),
        Domain(name: "Falun-sso", url: "falun-sso.skola24.se"),
        Domain(name: "Falun-test", url: "falun-test.skola24.se"),
        Domain(name: "Fastighetsakademin", url: "fastighetsakademin.skola24.se"),
        Domain(name: "Fhskhvilan", url: "fhskhvilan.skola24.se"),
        Domain(name: "Filipstad", url: "filipstad.skola24.se"),
        Domain(name: "Filmomusikgymnasiet", url: "filmomusikgymnasiet.skola24.se"),
        Domain(name: "Finspang", url: "finspang.skola24.se"),
        Domain(name: "Finspang-sso", url: "finspang-sso.skola24.se"),
        Domain(name: "Flen", url: "flen.skola24.se"),
        Domain(name: "Flenskristnaskola", url: "flenskristnaskola.skola24.se"),
        Domain(name: "Flen-sso", url: "flen-sso.skola24.se"),
        Domain(name: "Flyinge", url: "flyinge.skola24.se"),
        Domain(name: "Folkuniversitetetost", url: "folkuniversitetetost.skola24.se"),
        Domain(name: "Folkuniversitetetvast", url: "folkuniversitetetvast.skola24.se"),
        Domain(name: "Forshaga", url: "forshaga.skola24.se"),
        Domain(name: "Forshaga-foralder", url: "forshaga-foralder.skola24.se"),
        Domain(name: "Forshaga-sso", url: "forshaga-sso.skola24.se"),
        Domain(name: "Framtidsgymnasiet", url: "framtidsgymnasiet.skola24.se"),
        Domain(name: "Framtidskompassen", url: "framtidskompassen.skola24.se"),
        Domain(name: "Franskaskolangbg", url: "franskaskolangbg.skola24.se"),
        Domain(name: "Franskaskolansthlm", url: "franskaskolansthlm.skola24.se"),
        Domain(name: "Fredrikshov", url: "fredrikshov.skola24.se"),
        Domain(name: "Fredsbergsfriskola", url: "fredsbergsfriskola.skola24.se"),
        Domain(name: "Fredsborgskolan", url: "fredsborgskolan.skola24.se"),
        Domain(name: "Freinetskolanhugin", url: "freinetskolanhugin.skola24.se"),
        Domain(name: "Freinetskolanmimer", url: "freinetskolanmimer.skola24.se"),
        Domain(name: "Friaemilia", url: "friaemilia.skola24.se"),
        Domain(name: "Frialaroverken", url: "frialaroverken.skola24.se"),
        Domain(name: "Fridaskolorna", url: "fridaskolorna.skola24.se"),
        Domain(name: "Friskolanlyftet", url: "friskolanlyftet.skola24.se"),
        Domain(name: "Frisksportgarden", url: "frisksportgarden.skola24.se"),
        Domain(name: "Fristadsfhsk", url: "fristadsfhsk.skola24.se"),
        Domain(name: "Fryshuset", url: "fryshuset.skola24.se"),
        Domain(name: "Fryxellskaskolan", url: "fryxellskaskolan.skola24.se"),
        Domain(name: "Futuraskolan", url: "futuraskolan.skola24.se"),
        Domain(name: "Gagnef", url: "gagnef.skola24.se"),
        Domain(name: "Galaren", url: "galaren.skola24.se"),
        Domain(name: "Gavle", url: "gavle.skola24.se"),
        Domain(name: "Gavle-sso", url: "gavle-sso.skola24.se"),
        Domain(name: "Geflemontessoriskola", url: "geflemontessoriskola.skola24.se"),
        Domain(name: "Gellivare", url: "gellivare.skola24.se"),
        Domain(name: "Gislaved", url: "gislaved.skola24.se"),
        Domain(name: "Gladahudik", url: "gladahudik.skola24.se"),
        Domain(name: "Glimakrafhsk", url: "glimakrafhsk.skola24.se"),
        Domain(name: "Globen", url: "globen.skola24.se"),
        Domain(name: "Gnesta", url: "gnesta.skola24.se"),
        Domain(name: "Gnosjo", url: "gnosjo.skola24.se"),
        Domain(name: "Goteborg", url: "goteborg.skola24.se"),
        Domain(name: "Goteborgstekniskacollege", url: "goteborgstekniskacollege.skola24.se"),
        Domain(name: "Gotene", url: "gotene.skola24.se"),
        Domain(name: "Gotland", url: "gotland.skola24.se"),
        Domain(name: "Gotlandgrontcentrum", url: "gotlandgrontcentrum.skola24.se"),
        Domain(name: "Grans", url: "grans.skola24.se"),
        Domain(name: "Grastorp", url: "grastorp.skola24.se"),
        Domain(name: "Grebbestadsfhsk", url: "grebbestadsfhsk.skola24.se"),
        Domain(name: "Grennaskolan", url: "grennaskolan.skola24.se"),
        Domain(name: "Gripsholmsskolan", url: "gripsholmsskolan.skola24.se"),
        Domain(name: "Grums", url: "grums.skola24.se"),
        Domain(name: "Grundskolanaventyret", url: "grundskolanaventyret.skola24.se"),
        Domain(name: "Gryningeskolan", url: "gryningeskolan.skola24.se"),
        Domain(name: "Gti", url: "gti.skola24.se"),
        Domain(name: "Gullspang", url: "gullspang.skola24.se"),
        Domain(name: "Haabo", url: "haabo.skola24.se"),
        Domain(name: "Habo", url: "habo.skola24.se"),
        Domain(name: "Hagfors", url: "hagfors.skola24.se"),
        Domain(name: "Hallsberg", url: "hallsberg.skola24.se"),
        Domain(name: "Hallstahammar", url: "hallstahammar.skola24.se"),
        Domain(name: "Halmstad", url: "halmstad.skola24.se"),
        Domain(name: "Halmstad-mobil", url: "halmstad-mobil.skola24.se"),
        Domain(name: "Hammaro", url: "hammaro.skola24.se"),
        Domain(name: "Haninge", url: "haninge.skola24.se"),
        Domain(name: "Hannaskolan", url: "hannaskolan.skola24.se"),
        Domain(name: "Haparanda", url: "haparanda.skola24.se"),
        Domain(name: "Harjedalen", url: "harjedalen.skola24.se"),
        Domain(name: "Harnosand", url: "harnosand.skola24.se"),
        Domain(name: "Harryda", url: "harryda.skola24.se"),
        Domain(name: "Harryda-sso", url: "harryda-sso.skola24.se"),
        Domain(name: "Hassleholm", url: "hassleholm.skola24.se"),
        Domain(name: "Heby", url: "heby.skola24.se"),
        Domain(name: "Hedemora", url: "hedemora.skola24.se"),
        Domain(name: "Helixgymnasiet", url: "helixgymnasiet.skola24.se"),
        Domain(name: "Helleborusskolan", url: "helleborusskolan.skola24.se"),
        Domain(name: "Hellefors", url: "hellefors.skola24.se"),
        Domain(name: "Helsingborg", url: "helsingborg.skola24.se"),
        Domain(name: "Helsingborg-anst", url: "helsingborg-anst.skola24.se"),
        Domain(name: "Helsingborg-eid", url: "helsingborg-eid.skola24.se"),
        Domain(name: "Helsingborg-elev", url: "helsingborg-elev.skola24.se"),
        Domain(name: "Hermods", url: "hermods.skola24.se"),
        Domain(name: "Hermodsdcc", url: "hermodsdcc.skola24.se"),
        Domain(name: "Hermodsgymnasium", url: "hermodsgymnasium.skola24.se"),
        Domain(name: "Herrljunga", url: "herrljunga.skola24.se"),
        Domain(name: "Hjalmared", url: "hjalmared.skola24.se"),
        Domain(name: "Hjo", url: "hjo.skola24.se"),
        Domain(name: "Hjofhsk", url: "hjofhsk.skola24.se"),
        Domain(name: "HKKB", url: "HKKB.skola24.se"),
        Domain(name: "Hofors", url: "hofors.skola24.se"),
        Domain(name: "Hoganas", url: "hoganas.skola24.se"),
        Domain(name: "Hoganas-sso", url: "hoganas-sso.skola24.se"),
        Domain(name: "Hoganas-ssotest", url: "hoganas-ssotest.skola24.se"),
        Domain(name: "Hogsby", url: "hogsby.skola24.se"),
        Domain(name: "Honesta", url: "honesta.skola24.se"),
        Domain(name: "Hoor", url: "hoor.skola24.se"),
        Domain(name: "Horby", url: "horby.skola24.se"),
        Domain(name: "Huddinge", url: "huddinge.skola24.se"),
        Domain(name: "Huddinge-sso", url: "huddinge-sso.skola24.se"),
        Domain(name: "Hudiksvall", url: "hudiksvall.skola24.se"),
        Domain(name: "Hudiksvall-sso", url: "hudiksvall-sso.skola24.se"),
        Domain(name: "Hufb", url: "hufb.skola24.se"),
        Domain(name: "Hufb-sso", url: "hufb-sso.skola24.se"),
        Domain(name: "Hultsfred", url: "hultsfred.skola24.se"),
        Domain(name: "Hvilan", url: "hvilan.skola24.se"),
        Domain(name: "Hylte", url: "hylte.skola24.se"),
        Domain(name: "Idrottsgymnasiet", url: "idrottsgymnasiet.skola24.se"),
        Domain(name: "Ies", url: "ies.skola24.se"),
        Domain(name: "Imanskolan", url: "imanskolan.skola24.se"),
        Domain(name: "Ingridsegerstedt", url: "ingridsegerstedt.skola24.se"),
        Domain(name: "Ingridskolan", url: "ingridskolan.skola24.se"),
        Domain(name: "Initcollege", url: "initcollege.skola24.se"),
        Domain(name: "Inspira", url: "inspira.skola24.se"),
        Domain(name: "Intsch", url: "intsch.skola24.se"),
        Domain(name: "Isgr", url: "isgr.skola24.se"),
        Domain(name: "Issr", url: "issr.skola24.se"),
        Domain(name: "It-gymnasiet", url: "it-gymnasiet.skola24.se"),
        Domain(name: "Itslearning", url: "itslearning.skola24.se"),
        Domain(name: "Jamtlandsgymnasium", url: "jamtlandsgymnasium.skola24.se"),
        Domain(name: "Jarfalla", url: "jarfalla.skola24.se"),
        Domain(name: "Jarnanaturbruk", url: "jarnanaturbruk.skola24.se"),
        Domain(name: "Jenseneducation", url: "jenseneducation.skola24.se"),
        Domain(name: "Johannelund", url: "johannelund.skola24.se"),
        Domain(name: "Jokkmokk", url: "jokkmokk.skola24.se"),
        Domain(name: "Jonkoping", url: "jonkoping.skola24.se"),
        Domain(name: "Josefinaskolan", url: "josefinaskolan.skola24.se"),
        Domain(name: "Ju", url: "ju.skola24.se"),
        Domain(name: "Kaggeholmsfhsk", url: "kaggeholmsfhsk.skola24.se"),
        Domain(name: "Kalix", url: "kalix.skola24.se"),
        Domain(name: "Kalmar", url: "kalmar.skola24.se"),
        Domain(name: "Karinboyeskolan", url: "karinboyeskolan.skola24.se"),
        Domain(name: "Karlsborg", url: "karlsborg.skola24.se"),
        Domain(name: "Karlskoga", url: "karlskoga.skola24.se"),
        Domain(name: "Karlskogafhsk", url: "karlskogafhsk.skola24.se"),
        Domain(name: "Karlskrona", url: "karlskrona.skola24.se"),
        Domain(name: "Karlskrona-sso", url: "karlskrona-sso.skola24.se"),
        Domain(name: "Karlstad", url: "karlstad.skola24.se"),
        Domain(name: "Karlstad-personal", url: "karlstad-personal.skola24.se"),
        Domain(name: "Kastanjesskolan", url: "kastanjesskolan.skola24.se"),
        Domain(name: "Katarinaskolan", url: "katarinaskolan.skola24.se"),
        Domain(name: "Katolska", url: "katolska.skola24.se"),
        Domain(name: "Katrineholm", url: "katrineholm.skola24.se"),
        Domain(name: "Kavlinge", url: "kavlinge.skola24.se"),
        Domain(name: "Kil", url: "kil.skola24.se"),
        Domain(name: "Kil-foralder", url: "kil-foralder.skola24.se"),
        Domain(name: "Kil-sso", url: "kil-sso.skola24.se"),
        Domain(name: "Kinda", url: "kinda.skola24.se"),
        Domain(name: "Kinnarp", url: "kinnarp.skola24.se"),
        Domain(name: "Kiruna", url: "kiruna.skola24.se"),
        Domain(name: "Kistaschool", url: "kistaschool.skola24.se"),
        Domain(name: "Kitas", url: "kitas.skola24.se"),
        Domain(name: "Klaragymnasium", url: "klaragymnasium.skola24.se"),
        Domain(name: "Klippan", url: "klippan.skola24.se"),
        Domain(name: "Koping", url: "koping.skola24.se"),
        Domain(name: "Kramfors", url: "kramfors.skola24.se"),
        Domain(name: "Krikabygdeskola", url: "krikabygdeskola.skola24.se"),
        Domain(name: "Kriminalvarden", url: "kriminalvarden.skola24.se"),
        Domain(name: "Kristianstad", url: "kristianstad.skola24.se"),
        Domain(name: "Kristianstad-extern", url: "kristianstad-extern.skola24.se"),
        Domain(name: "Kristinaskolan", url: "kristinaskolan.skola24.se"),
        Domain(name: "Kristinehamn", url: "kristinehamn.skola24.se"),
        Domain(name: "Kristinehamnsfhsk", url: "kristinehamnsfhsk.skola24.se"),
        Domain(name: "Kristnaskolan", url: "kristnaskolan.skola24.se"),
        Domain(name: "Kristofferskolan", url: "kristofferskolan.skola24.se"),
        Domain(name: "Krokom", url: "krokom.skola24.se"),
        Domain(name: "Ksgyf", url: "ksgyf.skola24.se"),
        Domain(name: "Ksgyf-sso", url: "ksgyf-sso.skola24.se"),
        Domain(name: "Ktrehab", url: "ktrehab.skola24.se"),
        Domain(name: "Kubikskolan", url: "kubikskolan.skola24.se"),
        Domain(name: "Kullaviksmontessori", url: "kullaviksmontessori.skola24.se"),
        Domain(name: "Kulturskolanraketen", url: "kulturskolanraketen.skola24.se"),
        Domain(name: "Kumla", url: "kumla.skola24.se"),
        Domain(name: "Kumla-sso", url: "kumla-sso.skola24.se"),
        Domain(name: "Kungalv", url: "kungalv.skola24.se"),
        Domain(name: "Kungalv-sso", url: "kungalv-sso.skola24.se"),
        Domain(name: "Kungsbacka", url: "kungsbacka.skola24.se"),
        Domain(name: "Kungsor", url: "kungsor.skola24.se"),
        Domain(name: "Kunskapsforbundetvast", url: "kunskapsforbundetvast.skola24.se"),
        Domain(name: "Kunskapsforbundetvast-sso", url: "kunskapsforbundetvast-sso.skola24.se"),
        Domain(name: "Kunskapsskolan", url: "kunskapsskolan.skola24.se"),
        Domain(name: "Kunskapsskolan-sso", url: "kunskapsskolan-sso.skola24.se"),
        Domain(name: "Kvarnhjulet", url: "kvarnhjulet.skola24.se"),
        Domain(name: "Kvinnofhsk", url: "kvinnofhsk.skola24.se"),
        Domain(name: "Laholm", url: "laholm.skola24.se"),
        Domain(name: "Laholm-foralder", url: "laholm-foralder.skola24.se"),
        Domain(name: "Landskrona", url: "landskrona.skola24.se"),
        Domain(name: "Lapplandsgymnasium", url: "lapplandsgymnasium.skola24.se"),
        Domain(name: "Larlingsgymnasiet", url: "larlingsgymnasiet.skola24.se"),
        Domain(name: "Lavigruppen", url: "lavigruppen.skola24.se"),
        Domain(name: "Laxa", url: "laxa.skola24.se"),
        Domain(name: "Lbskreativagymnasiet", url: "lbskreativagymnasiet.skola24.se"),
        Domain(name: "Lekeberg", url: "lekeberg.skola24.se"),
        Domain(name: "Leksand", url: "leksand.skola24.se"),
        Domain(name: "Lel", url: "lel.skola24.se"),
        Domain(name: "Lemshaga", url: "lemshaga.skola24.se"),
        Domain(name: "Lernia", url: "lernia.skola24.se"),
        Domain(name: "Lerum", url: "lerum.skola24.se"),
        Domain(name: "Lessebo", url: "lessebo.skola24.se"),
        Domain(name: "Lhm", url: "lhm.skola24.se"),
        Domain(name: "Lidkoping", url: "lidkoping.skola24.se"),
        Domain(name: "Lillaakademien", url: "lillaakademien.skola24.se"),
        Domain(name: "Lillaedet", url: "lillaedet.skola24.se"),
        Domain(name: "Lillerudsgymnasiet", url: "lillerudsgymnasiet.skola24.se"),
        Domain(name: "Lindesberg", url: "lindesberg.skola24.se"),
        Domain(name: "Lindgardsskolan", url: "lindgardsskolan.skola24.se"),
        Domain(name: "Linkoping", url: "linkoping.skola24.se"),
        Domain(name: "Linkoping-mobil", url: "linkoping-mobil.skola24.se"),
        Domain(name: "Ljungby", url: "ljungby.skola24.se"),
        Domain(name: "Ljungby-sso", url: "ljungby-sso.skola24.se"),
        Domain(name: "Ljusdal", url: "ljusdal.skola24.se"),
        Domain(name: "Ljusskolan", url: "ljusskolan.skola24.se"),
        Domain(name: "Lme", url: "lme.skola24.se"),
        Domain(name: "Lomma", url: "lomma.skola24.se"),
        Domain(name: "Ludvika", url: "ludvika.skola24.se"),
        Domain(name: "Ludvika-mobil", url: "ludvika-mobil.skola24.se"),
        Domain(name: "Lulea", url: "lulea.skola24.se"),
        Domain(name: "Lund", url: "lund.skola24.se"),
        Domain(name: "Lundsberg", url: "lundsberg.skola24.se"),
        Domain(name: "Lundsmontessorigrundskola", url: "lundsmontessorigrundskola.skola24.se"),
        Domain(name: "Lund-sso", url: "lund-sso.skola24.se"),
        Domain(name: "Lundutbildning", url: "lundutbildning.skola24.se"),
        Domain(name: "Lund-vardnadshavare", url: "lund-vardnadshavare.skola24.se"),
        Domain(name: "Lunnevadsfhsk", url: "lunnevadsfhsk.skola24.se"),
        Domain(name: "Lustlara", url: "lustlara.skola24.se"),
        Domain(name: "Lycksele", url: "lycksele.skola24.se"),
        Domain(name: "Lysekil", url: "lysekil.skola24.se"),
        Domain(name: "Magnetica", url: "magnetica.skola24.se"),
        Domain(name: "Mala", url: "mala.skola24.se"),
        Domain(name: "Malmenmontessori", url: "malmenmontessori.skola24.se"),
        Domain(name: "Malmgruppen", url: "malmgruppen.skola24.se"),
        Domain(name: "Malmo", url: "malmo.skola24.se"),
        Domain(name: "Malmomonterssori", url: "malmomonterssori.skola24.se"),
        Domain(name: "Mandelaskolan", url: "mandelaskolan.skola24.se"),
        Domain(name: "Margarethaskolan", url: "margarethaskolan.skola24.se"),
        Domain(name: "Mariaelementar", url: "mariaelementar.skola24.se"),
        Domain(name: "Mariaskolan", url: "mariaskolan.skola24.se"),
        Domain(name: "Mariaskolanjarna", url: "mariaskolanjarna.skola24.se"),
        Domain(name: "Marieborgsfhsk", url: "marieborgsfhsk.skola24.se"),
        Domain(name: "Mariestad", url: "mariestad.skola24.se"),
        Domain(name: "Marinalaroverket", url: "marinalaroverket.skola24.se"),
        Domain(name: "Mark", url: "mark.skola24.se"),
        Domain(name: "Markaryd", url: "markaryd.skola24.se"),
        Domain(name: "Markarydsfhsk", url: "markarydsfhsk.skola24.se"),
        Domain(name: "Markaryd-sso", url: "markaryd-sso.skola24.se"),
        Domain(name: "Mark-sso", url: "mark-sso.skola24.se"),
        Domain(name: "Martinskolan", url: "martinskolan.skola24.se"),
        Domain(name: "Medleforsfhsk", url: "medleforsfhsk.skola24.se"),
        Domain(name: "Mellerud", url: "mellerud.skola24.se"),
        Domain(name: "Metapontum", url: "metapontum.skola24.se"),
        Domain(name: "Mikaelelias", url: "mikaelelias.skola24.se"),
        Domain(name: "Mikaelskolan", url: "mikaelskolan.skola24.se"),
        Domain(name: "Mimersgymnasium", url: "mimersgymnasium.skola24.se"),
        Domain(name: "Mimerskolan", url: "mimerskolan.skola24.se"),
        Domain(name: "Mjolby", url: "mjolby.skola24.se"),
        Domain(name: "Molndal", url: "molndal.skola24.se"),
        Domain(name: "Molndal-sso", url: "molndal-sso.skola24.se"),
        Domain(name: "Monsteras", url: "monsteras.skola24.se"),
        Domain(name: "Montessorigsm", url: "montessorigsm.skola24.se"),
        Domain(name: "Montessoriskolancentrum", url: "montessoriskolancentrum.skola24.se"),
        Domain(name: "Montessoriskolanflodasateri", url: "montessoriskolanflodasateri.skola24.se"),
        Domain(name: "Montessoriskolanskaret", url: "montessoriskolanskaret.skola24.se"),
        Domain(name: "Montessoriskolanvaxholm", url: "montessoriskolanvaxholm.skola24.se"),
        Domain(name: "Montessoriskolanvaxthuset", url: "montessoriskolanvaxthuset.skola24.se"),
        Domain(name: "Mora", url: "mora.skola24.se"),
        Domain(name: "Mora-foralder", url: "mora-foralder.skola24.se"),
        Domain(name: "Motala", url: "motala.skola24.se"),
        Domain(name: "Movingers", url: "movingers.skola24.se"),
        Domain(name: "Mubarakutbildning", url: "mubarakutbildning.skola24.se"),
        Domain(name: "Mullsjo", url: "mullsjo.skola24.se"),
        Domain(name: "Mullsjofhsk", url: "mullsjofhsk.skola24.se"),
        Domain(name: "Munkedal", url: "munkedal.skola24.se"),
        Domain(name: "Munkerods", url: "munkerods.skola24.se"),
        Domain(name: "Munkfors", url: "munkfors.skola24.se"),
        Domain(name: "Musikugglan", url: "musikugglan.skola24.se"),
        Domain(name: "Nacka", url: "nacka.skola24.se"),
        Domain(name: "Nassjo", url: "nassjo.skola24.se"),
        Domain(name: "Naturlara", url: "naturlara.skola24.se"),
        Domain(name: "Nbg", url: "nbg.skola24.se"),
        Domain(name: "Nhskolan", url: "nhskolan.skola24.se"),
        Domain(name: "Nora", url: "nora.skola24.se"),
        Domain(name: "Norberg", url: "norberg.skola24.se"),
        Domain(name: "Nordanstig", url: "nordanstig.skola24.se"),
        Domain(name: "Nordisktflygteknikcentrum", url: "nordisktflygteknikcentrum.skola24.se"),
        Domain(name: "Norrastrandskolan", url: "norrastrandskolan.skola24.se"),
        Domain(name: "Norrkoping", url: "norrkoping.skola24.se"),
        Domain(name: "Norrkoping-sso", url: "norrkoping-sso.skola24.se"),
        Domain(name: "Norrtalje", url: "norrtalje.skola24.se"),
        Domain(name: "Norrtalje-sso", url: "norrtalje-sso.skola24.se"),
        Domain(name: "Norrviken", url: "norrviken.skola24.se"),
        Domain(name: "Norsjo", url: "norsjo.skola24.se"),
        Domain(name: "Novacentertaby", url: "novacentertaby.skola24.se"),
        Domain(name: "Novademo", url: "novademo.skola24.se"),
        Domain(name: "Novamarknad", url: "novamarknad.skola24.se"),
        Domain(name: "Novas-adfs", url: "novas-adfs.skola24.se"),
        Domain(name: "Novas-azure", url: "novas-azure.skola24.se"),
        Domain(name: "Novasoftwareexempel", url: "novasoftwareexempel.skola24.se"),
        Domain(name: "Novasoftwareexempel-sso", url: "novasoftwareexempel-sso.skola24.se"),
        Domain(name: "Novasoftwaretest", url: "novasoftwaretest.skola24.se"),
        Domain(name: "Novas-ssaml", url: "novas-ssaml.skola24.se"),
        Domain(name: "Novia", url: "novia.skola24.se"),
        Domain(name: "Ntigymnasiet", url: "ntigymnasiet.skola24.se"),
        Domain(name: "Ntm", url: "ntm.skola24.se"),
        Domain(name: "Nvu", url: "nvu.skola24.se"),
        Domain(name: "Nyalaroverket", url: "nyalaroverket.skola24.se"),
        Domain(name: "Nyaskolan", url: "nyaskolan.skola24.se"),
        Domain(name: "Nybro", url: "nybro.skola24.se"),
        Domain(name: "Nykoping", url: "nykoping.skola24.se"),
        Domain(name: "Nykopingsenskilda", url: "nykopingsenskilda.skola24.se"),
        Domain(name: "Nykopingstrand", url: "nykopingstrand.skola24.se"),
        Domain(name: "Nykvarn", url: "nykvarn.skola24.se"),
        Domain(name: "Nynashamn", url: "nynashamn.skola24.se"),
        Domain(name: "Ockelbo", url: "ockelbo.skola24.se"),
        Domain(name: "Ockero", url: "ockero.skola24.se"),
        Domain(name: "Odeshog", url: "odeshog.skola24.se"),
        Domain(name: "Ofhsk", url: "ofhsk.skola24.se"),
        Domain(name: "Oknaskolan", url: "oknaskolan.skola24.se"),
        Domain(name: "Olinsgymnasiet", url: "olinsgymnasiet.skola24.se"),
        Domain(name: "Olofstrom", url: "olofstrom.skola24.se"),
        Domain(name: "Olympicaskolan", url: "olympicaskolan.skola24.se"),
        Domain(name: "Onnestadsgymnasiet", url: "onnestadsgymnasiet.skola24.se"),
        Domain(name: "Orebro", url: "orebro.skola24.se"),
        Domain(name: "Orebrobibl", url: "orebrobibl.skola24.se"),
        Domain(name: "Orebro-elev", url: "orebro-elev.skola24.se"),
        Domain(name: "Orebro-personal", url: "orebro-personal.skola24.se"),
        Domain(name: "Orebrowaldorf", url: "orebrowaldorf.skola24.se"),
        Domain(name: "Orebro-vardnadshavare", url: "orebro-vardnadshavare.skola24.se"),
        Domain(name: "Orjanskolan", url: "orjanskolan.skola24.se"),
        Domain(name: "Orkelljunga", url: "orkelljunga.skola24.se"),
        Domain(name: "Ornskoldsvik", url: "ornskoldsvik.skola24.se"),
        Domain(name: "Orsa", url: "orsa.skola24.se"),
        Domain(name: "Orust", url: "orust.skola24.se"),
        Domain(name: "Orust-sso", url: "orust-sso.skola24.se"),
        Domain(name: "Osby", url: "osby.skola24.se"),
        Domain(name: "Oskarshamn", url: "oskarshamn.skola24.se"),
        Domain(name: "Osteraker", url: "osteraker.skola24.se"),
        Domain(name: "Osteraker-sso", url: "osteraker-sso.skola24.se"),
        Domain(name: "Osteraker-vardnadshavare", url: "osteraker-vardnadshavare.skola24.se"),
        Domain(name: "Osterlensfhsk", url: "osterlensfhsk.skola24.se"),
        Domain(name: "Osthammar", url: "osthammar.skola24.se"),
        Domain(name: "Osthammar-sso", url: "osthammar-sso.skola24.se"),
        Domain(name: "Ovanaker", url: "ovanaker.skola24.se"),
        Domain(name: "Overkalix", url: "overkalix.skola24.se"),
        Domain(name: "Oxelosund", url: "oxelosund.skola24.se"),
        Domain(name: "Pajala", url: "pajala.skola24.se"),
        Domain(name: "Partille", url: "partille.skola24.se"),
        Domain(name: "Partille-sso", url: "partille-sso.skola24.se"),
        Domain(name: "Peab", url: "peab.skola24.se"),
        Domain(name: "Piltradsskolan", url: "piltradsskolan.skola24.se"),
        Domain(name: "Pitea", url: "pitea.skola24.se"),
        Domain(name: "Plusgymnasiet", url: "plusgymnasiet.skola24.se"),
        Domain(name: "Popsacademy", url: "popsacademy.skola24.se"),
        Domain(name: "Praktiska", url: "praktiska.skola24.se"),
        Domain(name: "Procivitas", url: "procivitas.skola24.se"),
        Domain(name: "Profilskolan", url: "profilskolan.skola24.se"),
        Domain(name: "Prolympianorr", url: "prolympianorr.skola24.se"),
        Domain(name: "Prolympiasyd", url: "prolympiasyd.skola24.se"),
        Domain(name: "Pysslingen", url: "pysslingen.skola24.se"),
        Domain(name: "Qvarnholmen", url: "qvarnholmen.skola24.se"),
        Domain(name: "Ragnhildgymnasiet", url: "ragnhildgymnasiet.skola24.se"),
        Domain(name: "Ragunda", url: "ragunda.skola24.se"),
        Domain(name: "Ralsen", url: "ralsen.skola24.se"),
        Domain(name: "Raoulwallenberg", url: "raoulwallenberg.skola24.se"),
        Domain(name: "Rattvik", url: "rattvik.skola24.se"),
        Domain(name: "Rattvik-sso", url: "rattvik-sso.skola24.se"),
        Domain(name: "Realgymnasiet-sso", url: "realgymnasiet-sso.skola24.se"),
        Domain(name: "Robertsfors", url: "robertsfors.skola24.se"),
        Domain(name: "Robinsonskola", url: "robinsonskola.skola24.se"),
        Domain(name: "Romosseskolan", url: "romosseskolan.skola24.se"),
        Domain(name: "Ronneby", url: "ronneby.skola24.se"),
        Domain(name: "Ronnebyaktiveramobilapp", url: "ronnebyaktiveramobilapp.skola24.se"),
        Domain(name: "Runofhsk", url: "runofhsk.skola24.se"),
        Domain(name: "Ryssbygymnasiet", url: "ryssbygymnasiet.skola24.se"),
        Domain(name: "Rytmus", url: "rytmus.skola24.se"),
        Domain(name: "Sabyholmsmontessori", url: "sabyholmsmontessori.skola24.se"),
        Domain(name: "Saffle", url: "saffle.skola24.se"),
        Domain(name: "Sala", url: "sala.skola24.se"),
        Domain(name: "Salem", url: "salem.skola24.se"),
        Domain(name: "Sallybauerskolan", url: "sallybauerskolan.skola24.se"),
        Domain(name: "Sameskolstyrelsen", url: "sameskolstyrelsen.skola24.se"),
        Domain(name: "Samskolan", url: "samskolan.skola24.se"),
        Domain(name: "Samskolan-mobil", url: "samskolan-mobil.skola24.se"),
        Domain(name: "Samskolan-vardnadshavare", url: "samskolan-vardnadshavare.skola24.se"),
        Domain(name: "Sandviken", url: "sandviken.skola24.se"),
        Domain(name: "Sandvikutbildning", url: "sandvikutbildning.skola24.se"),
        Domain(name: "Sanktamariaalsike", url: "sanktamariaalsike.skola24.se"),
        Domain(name: "Sanktthomas", url: "sanktthomas.skola24.se"),
        Domain(name: "Sater", url: "sater.skola24.se"),
        Domain(name: "Sater-sso", url: "sater-sso.skola24.se"),
        Domain(name: "Savsjo", url: "savsjo.skola24.se"),
        Domain(name: "Sbbfhsk", url: "sbbfhsk.skola24.se"),
        Domain(name: "Sidsjofristaende", url: "sidsjofristaende.skola24.se"),
        Domain(name: "Sigtuna", url: "sigtuna.skola24.se"),
        Domain(name: "Sigtuna-bankid", url: "sigtuna-bankid.skola24.se"),
        Domain(name: "Siks", url: "siks.skola24.se"),
        Domain(name: "Simrishamn", url: "simrishamn.skola24.se"),
        Domain(name: "Sis", url: "sis.skola24.se"),
        Domain(name: "Sjobo", url: "sjobo.skola24.se"),
        Domain(name: "Sjolins", url: "sjolins.skola24.se"),
        Domain(name: "Skapaskolan", url: "skapaskolan.skola24.se"),
        Domain(name: "Skara", url: "skara.skola24.se"),
        Domain(name: "Skara-bankid", url: "skara-bankid.skola24.se"),
        Domain(name: "Skara-mobil", url: "skara-mobil.skola24.se"),
        Domain(name: "Skargardsgymnasiet", url: "skargardsgymnasiet.skola24.se"),
        Domain(name: "Skarpnackfhsk", url: "skarpnackfhsk.skola24.se"),
        Domain(name: "Skattkammaron", url: "skattkammaron.skola24.se"),
        Domain(name: "Skelleftea", url: "skelleftea.skola24.se"),
        Domain(name: "SKF", url: "SKF.skola24.se"),
        Domain(name: "Skinnskatteberg", url: "skinnskatteberg.skola24.se"),
        Domain(name: "Skolanbergius", url: "skolanbergius.skola24.se"),
        Domain(name: "Skolfederation", url: "skolfederation.skola24.se"),
        Domain(name: "Skovde", url: "skovde.skola24.se"),
        Domain(name: "Skovde-foralder", url: "skovde-foralder.skola24.se"),
        Domain(name: "Skovde-personal", url: "skovde-personal.skola24.se"),
        Domain(name: "Skurup", url: "skurup.skola24.se"),
        Domain(name: "Smedjebacken", url: "smedjebacken.skola24.se"),
        Domain(name: "Snitz", url: "snitz.skola24.se"),
        Domain(name: "Soderhamn", url: "soderhamn.skola24.se"),
        Domain(name: "Soderkoping", url: "soderkoping.skola24.se"),
        Domain(name: "Sodertalje", url: "sodertalje.skola24.se"),
        Domain(name: "Sodertalje-sso", url: "sodertalje-sso.skola24.se"),
        Domain(name: "Sodertornsfriskola", url: "sodertornsfriskola.skola24.se"),
        Domain(name: "Solleftea", url: "solleftea.skola24.se"),
        Domain(name: "Sollentuna", url: "sollentuna.skola24.se"),
        Domain(name: "Solna", url: "solna.skola24.se"),
        Domain(name: "Solna-sso", url: "solna-sso.skola24.se"),
        Domain(name: "Solvesborg", url: "solvesborg.skola24.se"),
        Domain(name: "Solvesborg-bromolla", url: "solvesborg-bromolla.skola24.se"),
        Domain(name: "Solviksfhsk", url: "solviksfhsk.skola24.se"),
        Domain(name: "Sophiaskolan", url: "sophiaskolan.skola24.se"),
        Domain(name: "Sorsele", url: "sorsele.skola24.se"),
        Domain(name: "Sotenas", url: "sotenas.skola24.se"),
        Domain(name: "Sparregymnasium", url: "sparregymnasium.skola24.se"),
        Domain(name: "Sprakskolan", url: "sprakskolan.skola24.se"),
        Domain(name: "Sshl", url: "sshl.skola24.se"),
        Domain(name: "Staffanstorp", url: "staffanstorp.skola24.se"),
        Domain(name: "Stefanskolan", url: "stefanskolan.skola24.se"),
        Domain(name: "Stenbackeskolan", url: "stenbackeskolan.skola24.se"),
        Domain(name: "Stenungsund", url: "stenungsund.skola24.se"),
        Domain(name: "Stenungsund-sso", url: "stenungsund-sso.skola24.se"),
        Domain(name: "Sterikskatolskaskola", url: "sterikskatolskaskola.skola24.se"),
        Domain(name: "Stiftelsenbmsl", url: "stiftelsenbmsl.skola24.se"),
        Domain(name: "Stiftelsenmikaeliskolan", url: "stiftelsenmikaeliskolan.skola24.se"),
        Domain(name: "Stockholmgymnasium", url: "stockholmgymnasium.skola24.se"),
        Domain(name: "Stockholmsestetiska", url: "stockholmsestetiska.skola24.se"),
        Domain(name: "Stockholmsstadsmission", url: "stockholmsstadsmission.skola24.se"),
        Domain(name: "Storuman", url: "storuman.skola24.se"),
        Domain(name: "Strandskolan", url: "strandskolan.skola24.se"),
        Domain(name: "Strangnas", url: "strangnas.skola24.se"),
        Domain(name: "Strangnasmontessori", url: "strangnasmontessori.skola24.se"),
        Domain(name: "Strombacksfolkhogskola", url: "strombacksfolkhogskola.skola24.se"),
        Domain(name: "Stromma", url: "stromma.skola24.se"),
        Domain(name: "Strommanaturbruk", url: "strommanaturbruk.skola24.se"),
        Domain(name: "Stromsholm", url: "stromsholm.skola24.se"),
        Domain(name: "Stromstad", url: "stromstad.skola24.se"),
        Domain(name: "Stromsund", url: "stromsund.skola24.se"),
        Domain(name: "Sundbyberg", url: "sundbyberg.skola24.se"),
        Domain(name: "Sundsvall", url: "sundsvall.skola24.se"),
        Domain(name: "Sunne", url: "sunne.skola24.se"),
        Domain(name: "Surahammar", url: "surahammar.skola24.se"),
        Domain(name: "Svalnasskola", url: "svalnasskola.skola24.se"),
        Domain(name: "Svalov", url: "svalov.skola24.se"),
        Domain(name: "Svalovsmontessori", url: "svalovsmontessori.skola24.se"),
        Domain(name: "Svedala", url: "svedala.skola24.se"),
        Domain(name: "Svenskaskolanfuengirola", url: "svenskaskolanfuengirola.skola24.se"),
        Domain(name: "Svenskaskolanlondon", url: "svenskaskolanlondon.skola24.se"),
        Domain(name: "Svenskaskolannairobi", url: "svenskaskolannairobi.skola24.se"),
        Domain(name: "Sverigefinskaskolan", url: "sverigefinskaskolan.skola24.se"),
        Domain(name: "Sverigefinskaskolangbg", url: "sverigefinskaskolangbg.skola24.se"),
        Domain(name: "Sverigesridgymnasium", url: "sverigesridgymnasium.skola24.se"),
        Domain(name: "Svnaturbruk", url: "svnaturbruk.skola24.se"),
        Domain(name: "Svok", url: "svok.skola24.se"),
        Domain(name: "Sydnarkesutbfb", url: "sydnarkesutbfb.skola24.se"),
        Domain(name: "Taby", url: "taby.skola24.se"),
        Domain(name: "Tabyfriskola", url: "tabyfriskola.skola24.se"),
        Domain(name: "Tabyyrkesgymnasium", url: "tabyyrkesgymnasium.skola24.se"),
        Domain(name: "Tandlakarhogskolan", url: "tandlakarhogskolan.skola24.se"),
        Domain(name: "Tanum", url: "tanum.skola24.se"),
        Domain(name: "Tanum-sso", url: "tanum-sso.skola24.se"),
        Domain(name: "Tarnafhsk", url: "tarnafhsk.skola24.se"),
        Domain(name: "Tba", url: "tba.skola24.se"),
        Domain(name: "Theducation", url: "theducation.skola24.se"),
        Domain(name: "Theenglishschool", url: "theenglishschool.skola24.se"),
        Domain(name: "Thorengruppen", url: "thorengruppen.skola24.se"),
        Domain(name: "Ths", url: "ths.skola24.se"),
        Domain(name: "Tibble", url: "tibble.skola24.se"),
        Domain(name: "Tibro", url: "tibro.skola24.se"),
        Domain(name: "Tidaholm", url: "tidaholm.skola24.se"),
        Domain(name: "Tidaholm-sso", url: "tidaholm-sso.skola24.se"),
        Domain(name: "Tierp", url: "tierp.skola24.se"),
        Domain(name: "Tillskararakademin", url: "tillskararakademin.skola24.se"),
        Domain(name: "Timra", url: "timra.skola24.se"),
        Domain(name: "Tingsryd", url: "tingsryd.skola24.se"),
        Domain(name: "Tjorn", url: "tjorn.skola24.se"),
        Domain(name: "Tollarefhs", url: "tollarefhs.skola24.se"),
        Domain(name: "Tomelilla", url: "tomelilla.skola24.se"),
        Domain(name: "Toreboda", url: "toreboda.skola24.se"),
        Domain(name: "Tornadoskolan", url: "tornadoskolan.skola24.se"),
        Domain(name: "Torsas", url: "torsas.skola24.se"),
        Domain(name: "Torsby", url: "torsby.skola24.se"),
        Domain(name: "Tranas", url: "tranas.skola24.se"),
        Domain(name: "Tranemo", url: "tranemo.skola24.se"),
        Domain(name: "Trelleborg", url: "trelleborg.skola24.se"),
        Domain(name: "Trelleborg-sso", url: "trelleborg-sso.skola24.se"),
        Domain(name: "Trollhattan", url: "trollhattan.skola24.se"),
        Domain(name: "Trollhattan-sso", url: "trollhattan-sso.skola24.se"),
        Domain(name: "Trosa", url: "trosa.skola24.se"),
        Domain(name: "Trosa-sso", url: "trosa-sso.skola24.se"),
        Domain(name: "Tuc", url: "tuc.skola24.se"),
        Domain(name: "Tvetafriskola", url: "tvetafriskola.skola24.se"),
        Domain(name: "Tyreso", url: "tyreso.skola24.se"),
        Domain(name: "Tyreso-sso", url: "tyreso-sso.skola24.se"),
        Domain(name: "Uddevalla", url: "uddevalla.skola24.se"),
        Domain(name: "Ulricehamn", url: "ulricehamn.skola24.se"),
        Domain(name: "Ulricehamn-sso", url: "ulricehamn-sso.skola24.se"),
        Domain(name: "Umea", url: "umea.skola24.se"),
        Domain(name: "Umea-admin", url: "umea-admin.skola24.se"),
        Domain(name: "Umea-elev", url: "umea-elev.skola24.se"),
        Domain(name: "Umea-foralder", url: "umea-foralder.skola24.se"),
        Domain(name: "Umeawaldorfskola", url: "umeawaldorfskola.skola24.se"),
        Domain(name: "Upplandsbro", url: "upplandsbro.skola24.se"),
        Domain(name: "Upplandsvasby", url: "upplandsvasby.skola24.se"),
        Domain(name: "Uppsala", url: "uppsala.skola24.se"),
        Domain(name: "Uppsalamusikklasser", url: "uppsalamusikklasser.skola24.se"),
        Domain(name: "Uppsala-sso", url: "uppsala-sso.skola24.se"),
        Domain(name: "Uppvidinge", url: "uppvidinge.skola24.se"),
        Domain(name: "Utbildningsinstitut", url: "utbildningsinstitut.skola24.se"),
        Domain(name: "Utv", url: "utv.skola24.se"),
        Domain(name: "Utvardering", url: "utvardering.skola24.se"),
        Domain(name: "Utvarderingnxt", url: "utvarderingnxt.skola24.se"),
        Domain(name: "Utvecklingspedagogik", url: "utvecklingspedagogik.skola24.se"),
        Domain(name: "Vackstanas", url: "vackstanas.skola24.se"),
        Domain(name: "Vadstena", url: "vadstena.skola24.se"),
        Domain(name: "Vaggeryd", url: "vaggeryd.skola24.se"),
        Domain(name: "Valdemarsvik", url: "valdemarsvik.skola24.se"),
        Domain(name: "Wallbergsskolan", url: "wallbergsskolan.skola24.se"),
        Domain(name: "Vallentunafriskola", url: "vallentunafriskola.skola24.se"),
        Domain(name: "Vallentunagrundskola", url: "vallentunagrundskola.skola24.se"),
        Domain(name: "Vallentunagymnasium", url: "vallentunagymnasium.skola24.se"),
        Domain(name: "Vanadisskolan", url: "vanadisskolan.skola24.se"),
        Domain(name: "Vanergymnasiet", url: "vanergymnasiet.skola24.se"),
        Domain(name: "Vanersborg", url: "vanersborg.skola24.se"),
        Domain(name: "Vanersborgsbibliotek", url: "vanersborgsbibliotek.skola24.se"),
        Domain(name: "Vannas", url: "vannas.skola24.se"),
        Domain(name: "Vansbro", url: "vansbro.skola24.se"),
        Domain(name: "Vara", url: "vara.skola24.se"),
        Domain(name: "Varberg", url: "varberg.skola24.se"),
        Domain(name: "Varberg-personal", url: "varberg-personal.skola24.se"),
        Domain(name: "Varberg-vardnadshavare", url: "varberg-vardnadshavare.skola24.se"),
        Domain(name: "Vargarda", url: "vargarda.skola24.se"),
        Domain(name: "Varmdo", url: "varmdo.skola24.se"),
        Domain(name: "Varnamo", url: "varnamo.skola24.se"),
        Domain(name: "Varnamofhsk", url: "varnamofhsk.skola24.se"),
        Domain(name: "Vasaskolangbg", url: "vasaskolangbg.skola24.se"),
        Domain(name: "Vasastansmontessori", url: "vasastansmontessori.skola24.se"),
        Domain(name: "Vastbergaskolan", url: "vastbergaskolan.skola24.se"),
        Domain(name: "Vasteras", url: "vasteras.skola24.se"),
        Domain(name: "Vasterasbibl", url: "vasterasbibl.skola24.se"),
        Domain(name: "Vasterhaningemontessori", url: "vasterhaningemontessori.skola24.se"),
        Domain(name: "Vastraekoskolan", url: "vastraekoskolan.skola24.se"),
        Domain(name: "Vattenfallsgymnasiet", url: "vattenfallsgymnasiet.skola24.se"),
        Domain(name: "Vaxholm", url: "vaxholm.skola24.se"),
        Domain(name: "Vaxholm-adfs", url: "vaxholm-adfs.skola24.se"),
        Domain(name: "Vaxholm-admin", url: "vaxholm-admin.skola24.se"),
        Domain(name: "Vaxholm-mobil", url: "vaxholm-mobil.skola24.se"),
        Domain(name: "Vaxjo", url: "vaxjo.skola24.se"),
        Domain(name: "Vaxjofria", url: "vaxjofria.skola24.se"),
        Domain(name: "Vaxjoislamiskaskola", url: "vaxjoislamiskaskola.skola24.se"),
        Domain(name: "Vellinge", url: "vellinge.skola24.se"),
        Domain(name: "Vesterhavsskolan", url: "vesterhavsskolan.skola24.se"),
        Domain(name: "Vetenskapsskolan", url: "vetenskapsskolan.skola24.se"),
        Domain(name: "Vetlanda", url: "vetlanda.skola24.se"),
        Domain(name: "Vfhs", url: "vfhs.skola24.se"),
        Domain(name: "Vgregion", url: "vgregion.skola24.se"),
        Domain(name: "Vgregionfhsk", url: "vgregionfhsk.skola24.se"),
        Domain(name: "Vibyfriskola", url: "vibyfriskola.skola24.se"),
        Domain(name: "Vibyskolan", url: "vibyskolan.skola24.se"),
        Domain(name: "Victoriaskolan", url: "victoriaskolan.skola24.se"),
        Domain(name: "Videdalsprivatskolor", url: "videdalsprivatskolor.skola24.se"),
        Domain(name: "Viktoriaskolanorebro", url: "viktoriaskolanorebro.skola24.se"),
        Domain(name: "Viktorrydbergsskolor", url: "viktorrydbergsskolor.skola24.se"),
        Domain(name: "Wilhelmhaglundsgy", url: "wilhelmhaglundsgy.skola24.se"),
        Domain(name: "Vilhelmina", url: "vilhelmina.skola24.se"),
        Domain(name: "Vimmerby", url: "vimmerby.skola24.se"),
        Domain(name: "Vindeln", url: "vindeln.skola24.se"),
        Domain(name: "Vingaker", url: "vingaker.skola24.se"),
        Domain(name: "Virestad", url: "virestad.skola24.se"),
        Domain(name: "Vittra", url: "vittra.skola24.se"),
        Domain(name: "Volvogymnasiet", url: "volvogymnasiet.skola24.se"),
        Domain(name: "Vrg", url: "vrg.skola24.se"),
        Domain(name: "Vuxenskolan", url: "vuxenskolan.skola24.se"),
        Domain(name: "Ydre", url: "ydre.skola24.se"),
        Domain(name: "Ystad", url: "ystad.skola24.se")
    ]
    
    static let headers: HTTPHeaders = [
        "Cookie": "ASP.NET_SessionId=ikj2emwf3rd10b2v1dy212c0; ASP.NET_SessionId=mbawd5bm2q4g2smpjc1dccre",
        "Host": "web.skola24.se",
        "X-Scope": "8a22163c-8662-4535-9050-bc5e1923df48"
    ]
    
    // static let hostName: String = "lulea.skola24.se"
    
    static func getSignature(userId: String, completion: @escaping (String?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/encrypt/signature", method: .post, parameters: JSON(["signature": userId]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                completion(json["data"]["signature"].rawString()!, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta signatur"))
            }
        }
    }
    
    static func getSchools(hostName: String, completion: @escaping ([School]?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/services/skola24/get/timetable/viewer/units", method: .post, parameters: JSON(["getTimetableViewerUnitsRequest": ["hostName": hostName]]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                var foundUnits: [School] = []
                let json = try JSON(data: response.data!)
                for (_, subJSON) in json["data"]["getTimetableViewerUnitsResponse"]["units"] {
                    foundUnits.append(School(unitGuid: subJSON["unitGuid"].rawString()!, unitId: subJSON["unitId"].rawString()!, hostName: hostName))
                }
                completion(foundUnits, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta skolor"))
            }
        }
    }
    
    static func getClasses(school: School, completion: @escaping ([s24_Class]?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/get/timetable/selection", method: .post, parameters: JSON(["hostName": school.hostName, "unitGuid": school.unitGuid, "filters": ["class": true, "course": false, "group": false, "period": false, "room": false, "student": false, "subject": false, "teacher": false]]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                var classList: [s24_Class] = []
                for val in json["data"]["classes"].arrayValue {
                    classList.append(s24_Class(name: val["groupName"].rawString()!, groupGuid: val["groupGuid"].rawString()!))
                }
                completion(classList, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta klasser"))
            }
        }
    }
    
    static func getTeachers(school: School, completion: @escaping ([Teacher]?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/get/timetable/selection", method: .post, parameters: JSON(["hostName": school.hostName, "unitGuid": school.unitGuid, "filters": ["class": false, "course": false, "group": false, "period": false, "room": false, "student": false, "subject": false, "teacher": true]]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                var teacherList: [Teacher] = []
                for val in json["data"]["teachers"].arrayValue {
                    teacherList.append(Teacher(firstName: val["firstName"].rawString()!, lastName: val["lastName"].rawString()!, id: val["id"].rawString()!, personGuid: val["personGuid"].rawString()!))
                }
                completion(teacherList, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta lärare"))
            }
        }
    }
    
    static func getTimetable(selection: String, selectionType: Int, size: CGSize, school: School, week: Int, completion: @escaping((JSON?, FetchError?) -> ())) {
        
        getRenderKey() { (key, fetchError) in
            if (fetchError != nil) {
                completion(nil, fetchError)
                return
            }
            else if(key == nil) {
                completion(nil, FetchError(message: "Kunde inte ladda nyckeln"))
            }
            AF.request("https://web.skola24.se/api/render/timetable", method: .post, parameters: JSON([
                    "selection": selection,
                    "unitGuid": school.unitGuid,
                    "selectionType": selectionType,
                    "blackAndWhite": false,
                    "startDate": JSON.null,
                    "endDate": JSON.null,
                    "height": size.height,
                    "width": size.width,
                    "renderKey": key,
                    "host": school.hostName,
                    "periodText": "",
                    "privateMode": JSON.null,
                    "scheduleDay": 0,
                    "showHeader": false,
                    "week": week
            ]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
                do {
                    if (response.data == nil) {
                        throw NSError()
                    }
                    let json = try JSON(data: response.data!)
                    let rawTimetableString = json["data"]["timetableJson"].rawString()
                    
                    let strData = rawTimetableString!.data(using: String.Encoding.utf8, allowLossyConversion: false)
                    let jsonData: JSON = try JSON(data: strData!)
                    completion(jsonData, nil)
                } catch {
                    completion(nil, FetchError(message: "Kunde inte hämta vecka"))
                }
            }
            
        }
        
        
    }
    
    
    static func getRenderKey(completion: @escaping (String?, FetchError?) -> ()) {
        AF.request("https://web.skola24.se/api/get/timetable/render/key", method: .post, parameters: JSON([
            JSON.null
        ]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json = try JSON(data: response.data!)
                
                let key = json["data"]["key"]
                completion(key.stringValue, nil)
            } catch {
                completion(nil, FetchError(message: "Kunde inte hämta renderingsnyckel"))
            }
        }
    }
    
    static func getObjectTimetable(selection: String, selectionType: Int, school: School, timeframe: Timeframe, selectedDate: Date, completion: @escaping ([Event], FetchError?) -> ()) {
        getRenderKey() { (key, fetchError) in
        if (fetchError != nil) {
            completion([], fetchError)
            return
        }
        else if(key == nil) {
            completion([], FetchError(message: "Kunde inte ladda nyckeln"))
        }
        AF.request("https://web.skola24.se/api/render/timetable", method: .post, parameters: JSON([
                "selection": selection,
                "unitGuid": school.unitGuid,
                "selectionType": selectionType,
                "blackAndWhite": false,
                "startDate": Timeframe.formatDateToString(date: timeframe.start),
                "endDate": Timeframe.formatDateToString(date: timeframe.end),
                "height": 700,
                //"width": 732,
                "width": 1200,
                "renderKey": key,
                "host": school.hostName,
                "periodText": "Period text",
                "privateMode": false,
                "scheduleDay": timeframe.dayOfWeek,
                "showHeader": false,
                "week": JSON.null
        ]), encoder: JSONParameterEncoder.sortedKeys, headers: headers).responseJSON { response in
            do {
                if (response.data == nil) {
                    throw NSError()
                }
                let json:JSON = try JSON(data: response.data!)
                let rawTimetableString = json["data"]["timetableJson"].rawString()
                
                let strData = rawTimetableString!.data(using: String.Encoding.utf8, allowLossyConversion: false)
                let timetable: JSON = try JSON(data: strData!)["textList"]
                let boxList: JSON = try JSON(data: strData!)["boxList"]
                
                // let filteredBoxList = boxList.arrayValue.filter {$0["height"] > 20 && $0["width"] > 100 && $0["y"] != 0 && $0["bcolor"] != "#CCCCCC" && $0["bcolor"] != "#FFFFFF"}

                var filteredBoxList = boxList.arrayValue.filter {$0["height"] > 22 && $0["width"] > 100 && $0["y"] != 0 && $0["bcolor"] != "#CCCCCC"}
                filteredBoxList.remove(at: 0)

                
                let filteredTimetable = timetable.arrayValue.filter {$0["text"] != ""}
                
                var sortedTimetable = filteredTimetable.sorted { u1, u2 in
                    return (u1["y"], u1["x"]) < (u2["y"], u2["x"])
                }
                
                /*var sortedTimetable = filteredTimetable.sorted { u1, u2 in
                    //return (u1["y"], u1["x"]) < (u2["y"], u2["x"])
                    return u1["y"] > u2["y"]
                }*/
                
                sortedTimetable.removeFirst(1)
                var eventList: [Event] = []
                
                let timeRegex = #"^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]"#
                
                for box in filteredBoxList {
                    var working: Event = Event(start: Date(), end: Date(), title: "", information: "")
                    var startDateY = -1
                    var endDateY = -1
                    
                    working.x = box["x"].intValue
                    working.y = box["y"].intValue
                    working.width = box["width"].intValue
                    working.height = box["height"].intValue
                                       
                    for drawText in sortedTimetable {
                        if (box["x"].intValue <= drawText["x"].intValue && drawText["x"].intValue <= box["x"].intValue + box["width"].intValue && box["y"].intValue - 10 <= drawText["y"].intValue && drawText["y"].intValue <= box["y"].intValue + box["height"].intValue) {
                            if (drawText["text"].rawString()?.range(of: timeRegex, options: .regularExpression) != nil) {
                                if (drawText["x"].intValue == box["x"].intValue + 1 && startDateY == -1) {
                                    startDateY = drawText["y"].intValue
                                    working.start = TodayController.newDateFromHourMinuteString(hourMinuteString: drawText["text"].rawString()!, from: selectedDate)
                                    working.hasStart = true
                                    //working.end = TodayDelegate.newDateFromHourMinuteString(hourMinuteString: drawText["text"].rawString()!)
                                    continue
                                }
                                else if (drawText["x"].intValue > box["x"].intValue + 5 /*&& endDateY == -1 && startDateY < drawText["y"].intValue*/) {
                                    endDateY = drawText["y"].intValue
                                    working.end = TodayController.newDateFromHourMinuteString(hourMinuteString: drawText["text"].rawString()!, from: selectedDate)
                                    working.hasEnd = true
                                    continue
                                }
                                continue
                            }
                            if (working.title == "") {
                                working.title = drawText["text"].rawString()!
                                continue
                            }
                            working.information = working.information + " " + drawText["text"].rawString()!
                            working.information = working.information.trimmingCharacters(in: [" "])
                        }
                    }
                    eventList.append(working)
                }
                
                for index in 0..<eventList.count {
                    
                    /* if (!eventList[index].hasEnd && !eventList[index].hasStart) {
                        print("Found event with no start and no end")
                        for event2 in eventList {
                            if (event2.hasEnd && eventList[index].y + eventList[index].height == event2.y + event2.height) {
                                print("Found new end for event")
                                eventList[index].end = event2.end
                                break
                            }
                        }
                        for event2 in eventList {
                            if (event2.hasStart && eventList[index].y == event2.y) {
                                print("Found new start for event")
                                eventList[index].start = event2.start
                                eventList[index].hasStart = true
                                break
                            }
                        }
                    } else {*/
                        if (!eventList[index].hasStart) {
                            for event2 in eventList {
                                if (event2.hasStart && eventList[index].y == event2.y) {
                                    eventList[index].start = event2.start
                                    eventList[index].hasStart = true
                                    break
                                }
                            }
                        }
                        if (!eventList[index].hasEnd) {
                            for event2 in eventList {
                                if (event2.hasEnd && eventList[index].y + eventList[index].height == event2.y + event2.height) {
                                    eventList[index].end = event2.end
                                    eventList[index].hasEnd = true
                                    break
                                }
                            }
                        }
                    }
                    
                // }
                for index in 0..<eventList.count {
                }
                eventList = eventList.filter {!$0.title.lowercased().contains("lunch")}
                eventList = eventList.sorted {
                    $0.start < $1.start
                }
                completion(eventList, nil)
            } catch {
                completion([], FetchError(message: "Kunde bygga idag-vy"))
            }
        }
        }
    }
}
