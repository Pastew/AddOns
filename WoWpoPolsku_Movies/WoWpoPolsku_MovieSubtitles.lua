-- Addon: WoWpoPolsku-Movies (version: 1.08) 2020.11.11
-- Description: AddOn displays translated subtitles during playing cinematics or movies.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)

-- General Variables
local MF_version = GetAddOnMetadata("WoWpoPolsku_Movies", "Version");
local MF_race = UnitRace("player");
local MF_class = UnitClass("player");
local MF_name = UnitName("player");
local MF_movieID, MF_SubTitle, MF_lp, MF_ID, MF_playing, MF_showing, MF_timer, MF_time1, MF_last_ST, MF_pytanie1, MF_pytanie2;
if (MF_class == "Death Knight") then
   MF_race = MF_class;
end

-- fonty z polskimi znakami diakrytycznymi
local MF_Font = "Interface\\AddOns\\WoWpoPolsku_Movies\\Fonts\\frizquadratatt_pl.ttf";

local player_race, player_class;
local p_race = {
      ["Blood Elf"] = { M1="Krwawy Elf", D1="krwawego elfa", C1="krwawemu elfowi", B1="krwawego elfa", N1="krwawym elfem", K1="krwawym elfie", W1="Krwawy Elfie", M2="Krwawa Elfka", D2="krwawej elfki", C2="krwawej elfce", B2="krwawą elfkę", N2="krwawą elfką", K2="krwawej elfce", W2="Krwawa Elfko" }, 
      ["Dark Iron Dwarf"] = { M1="Krasnolud Ciemnego Żelaza", D1="krasnoluda Ciemnego Żelaza", C1="krasnoludowi Ciemnego Żelaza", B1="krasnoluda Ciemnego Żelaza", N1="krasnoludem Ciemnego Żelaza", K1="krasnoludzie Ciemnego Żelaza", W1="Krasnoludzie Ciemnego Żelaza", M2="Krasnoludka Ciemnego Żelaza", D2="krasnoludki Ciemnego Żelaza", C2="krasnoludce Ciemnego Żelaza", B2="krasnoludkę Ciemnego Żelaza", N2="krasnoludką Ciemnego Żelaza", K2="krasnoludce Ciemnego Żelaza", W2="Krasnoludko Ciemnego Żelaza" },
      ["Draenei"] = { M1="Draenei", D1="draeneia", C1="draeneiowi", B1="draeneia", N1="draeneiem", K1="draeneiu", W1="Draeneiu", M2="Draeneika", D2="draeneiki", C2="draeneice", B2="draeneikę", N2="draeneiką", K2="draeneice", W2="Draeneiko" },
      ["Dwarf"] = { M1="Krasnolud", D1="krasnoluda", C1="krasnoludowi", B1="krasnoluda", N1="krasnoludem", K1="krasnoludzie", W1="Krasnoludzie", M2="Krasnoludka", D2="krasnoludki", C2="krasnoludce", B2="krasnoludkę", N2="krasnoludką", K2="krasnoludce", W2="Krasnoludko" },
      ["Gnome"] = { M1="Gnom", D1="gnoma", C1="gnomowi", B1="gnoma", N1="gnomem", K1="gnomie", W1="Gnomie", M2="Gnomka", D2="gnomki", C2="gnomce", B2="gnomkę", N2="gnomką", K2="gnomce", W2="Gnomko" },
      ["Goblin"] = { M1="Goblin", D1="goblina", C1="goblinowi", B1="goblina", N1="goblinem", K1="goblinie", W1="Goblinie", M2="Goblinka", D2="goblinki", C2="goblince", B2="goblinkę", N2="goblinką", K2="goblince", W2="Goblinko" },
      ["Highmountain Tauren"] = { M1="Tauren z Wysokiej Góry", D1="taurena z Wysokiej Góry", C1="taurenowi z Wysokiej Góry", B1="taurena z Wysokiej Góry", N1="taurenen z Wysokiej Góry", K1="taurenie z Wysokiej Góry", W1="Taurenie z Wysokiej Góry", M2="Taurenka z Wysokiej Góry", D2="taurenki z Wysokiej Góry", C2="taurence z Wysokiej Góry", B2="taurenkę z Wysokiej Góry", N2="taurenką z Wysokiej Góry", K2="taurence z Wysokiej Góry", W2="Taurenko z Wysokiej Góry" },
      ["Human"] = { M1="Człowiek", D1="człowieka", C1="człowiekowi", B1="człowieka", N1="człowiekiem", K1="człowieku", W1="Człowieku", M2="Człowiek", D2="człowieka", C2="człowiekowi", B2="człowieka", N2="człowiekiem", K2="człowieku", W2="Człowieku" },
      ["Kul Tiran Human"] = { M1="Człowiek z Kul Tiran", D1="człowieka z Kul Tiran", C1="człowiekowi z Kul Tiran", B1="człowieka z Kul Tiran", N1="człowiekiem z Kul Tiran", K1="człowieku z Kul Tiran", W1="Człowieku z Kul Tiran", M2="Człowiek z Kul Tiran", D2="człowieka z Kul Tiran", C2="człowiekowi z Kul Tiran", B2="człowieka z Kul Tiran", N2="człowiekiem z Kul Tiran", K2="człowieku z Kul Tiran", W2="Człowieku z Kul Tiran" },
      ["Lightforged Draenei"] = { M1="Świetlisty Draenei", D1="świetlistego draeneia", C1="świetlistemu draeneiowi", B1="świetlistego draeneia", N1="świetlistym draeneiem", K1="świetlistym draeneiu", W1="Świetlisty Draeneiu", M2="Świetlista Draeneika", D2="świetlistej draeneiki", C2="świetlistej draeneice", B2="świetlistą draeneikę", N2="świetlistą draeneiką", K2="świetlistej draeneice", W2="Świetlista Draeneiko" },
      ["Mag'har Orc"] = { M1="Ork z Mag'har", D1="orka z Mag'har", C1="orkowi z Mag'har", B1="orka z Mag'har", N1="orkiem z Mag'har", K1="orku z Mag'har", W1="Orku z Mag'har", M2="Orczyca z Mag'har", D2="orczycy z Mag'har", C2="orczycy z Mag'har", B2="orczycę z Mag'har", N2="orczycą z Mag'har", K2="orczyce z Mag'har", W2="Orczyco z Mag'har" },
      ["Nightborne"] = { M1="Dziecię Nocy", D1="dziecięcia nocy", C1="dziecięciu nocy", B1="dziecię nocy", N1="dziecięcem nocy", K1="dziecięciu nocy", W1="Dziecię Nocy", M2="Dziecię Nocy", D2="dziecięcia nocy", C2="dziecięciu nocy", B2="dziecię nocy", N2="dziecięcem nocy", K2="dziecięciu nocy", W2="Dziecię Nocy" },
      ["Night Elf"] = { M1="Nocny Elf", D1="nocnego elfa", C1="nocnemu elfowi", B1="nocnego elfa", N1="nocnym elfem", K1="nocnym elfie", W1="Nocny Elfie", M2="Nocna Elfka", D2="nocnej elfki", C2="nocnej elfce", B2="nocną elfkę", N2="nocną elfką", K2="nocnej elfce", W2="Nocna Elfko" },
      ["Orc"] = { M1="Ork", D1="orka", C1="orkowi", B1="orka", N1="orkiem", K1="orku", W1="Orku", M2="Orczyca", D2="orczycy", C2="orczycy", B2="orczycę", N2="orczycą", K2="orczycy", W2="Orczyco" },
      ["Pandaren"] = { M1="Pandaren", D1="pandarena", C1="pandarenowi", B1="pandarena", N1="pandarenem", K1="pandarenie", W1="Pandarenie", M2="Pandarenka", D2="pandarenki", C2="pandarence", B2="pandarenkę", N2="pandarenką", K2="pandarence", W2="Pandarenko" },
      ["Tauren"] = { M1="Tauren", D1="taurena", C1="taurenowi", B1="taurena", N1="taurenem", K1="taurenie", W1="Taurenie", M2="Taurenka", D2="taurenki", C2="taurence", B2="taurenkę", N2="taurenką", K2="taurence", W2="Taurenko" },
      ["Troll"] = { M1="Troll", D1="trolla", C1="trollowi", B1="trolla", N1="trollem", K1="trollu", W1="Trollu", M2="Trollica", D2="trollicy", C2="trollicy", B2="trollicę", N2="trollicą", K2="trollicy", W2="Trollico" },
      ["Undead"] = { M1="Nieumarły", D1="nieumarłego", C1="nieumarłemu", B1="nieumarłego", N1="nieumarłym", K1="nieumarłym", W1="Nieumarły", M2="Nieumarła", D2="nieumarłej", C2="nieumarłej", B2="nieumarłą", N2="nieumarłą", K2="nieumarłej", W2="Nieumarła" },
      ["Void Elf"] = { M1="Elf Pustki", D1="elfa Pustki", C1="elfowi Pustki", B1="elfa Pustki", N1="elfem Pustki", K1="elfie Pustki", W1="Elfie Pustki", M2="Elfka Pustki", D2="elfki Pustki", C2="elfce Pustki", B2="elfkę Pustki", N2="elfką Pustki", K2="elfce Pustki", W2="Elfko Pustki" },
      ["Worgen"] = { M1="Worgen", D1="worgena", C1="worgenowi", B1="worgena", N1="worgenem", K1="worgenie", W1="Worgenie", M2="Worgenka", D2="worgenki", C2="worgence", B2="worgenkę", N2="worgenką", K2="worgence", W2="Worgenko" },
      ["Zandalari Troll"] = { M1="Troll z Zandalari", D1="trolla z Zandalari", C1="trollowi z Zandalari", B1="trolla z Zandalari", N1="trollem z Zandalari", K1="trollu z Zandalari", W1="Trollu z Zandalari", M2="Trollica z Zandalari", D2="trollicy z Zandalari", C2="trollicy z Zandalari", B2="trollicę z Zandalari", N2="trollicą z Zandalari", K2="trollicy z Zandalari", W2="Trollico z Zandalari" }, }
local p_class = {
      ["Death Knight"] = { M1="Rycerz Śmierci", D1="rycerz śmierci", C1="rycerzowi śmierci", B1="rycerza śmierci", N1="rycerzem śmierci", K1="rycerzu śmierci", W1="Rycerzu Śmierci", M2="Rycerz Śmierci", D2="rycerz śmierci", C2="rycerzowi śmierci", B2="rycerza śmierci", N2="rycerzem śmierci", K2="rycerzu śmierci", W2="Rycerzu Śmierci" },
      ["Demon Hunter"] = { M1="Łowca demonów", D1="łowcy demonów", C1="łowcy demonów", B1="łowcę demonów", N1="łowcą demonów", K1="łowcy demonów", W1="Łowco demonów", M2="Łowczyni demonów", D2="łowczyni demonów", C2="łowczyni demonów", B2="łowczynię demonów", N2="łowczynią demonów", K2="łowczyni demonów", W2="Łowczyni demonów" },
      ["Druid"] = { M1="Druid", D1="druida", C1="druidowi", B1="druida", N1="druidem", K1="druidzie", W1="Druidzie", M2="Druidka", D2="druidki", C2="druidce", B2="druikę", N2="druidką", K2="druidce", W2="Druidko" },
      ["Hunter"] = { M1="Łowca", D1="łowcy", C1="łowcy", B1="łowcę", N1="łowcą", K1="łowcy", W1="Łowco", M2="Łowczyni", D2="łowczyni", C2="łowczyni", B2="łowczynię", N2="łowczynią", K2="łowczyni", W2="Łowczyni" },
      ["Mage"] = { M1="Czarodziej", D1="czarodzieja", C1="czarodziejowi", B1="czarodzieja", N1="czarodziejem", K1="czarodzieju", W1="Czarodzieju", M2="Czarodziejka", D2="czarodziejki", C2="czarodziejce", B2="czarodziejkę", N2="czarodziejką", K2="czarodziejce", W2="Czarodziejko" },
      ["Monk"] = { M1="Mnich", D1="mnicha", C1="mnichowi", B1="mnicha", N1="mnichem", K1="mnichu", W1="Mnichu", M2="Mniszka", D2="mniszki", C2="mniszce", B2="mniszkę", N2="mniszką", K2="mniszce", W2="Mniszko" },
      ["Paladin"] = { M1="Paladyn", D1="paladyna", C1="paladynowi", B1="paladyna", N1="paladynem", K1="paladynie", W1="Paladynie", M2="Paladynka", D2="paladynki", C2="paladynce", B2="paladynkę", N2="paladynką", K2="paladynce", W2="Paladynko" },
      ["Priest"] = { M1="Kapłan", D1="kapłana", C1="kapłanowi", B1="kapłana", N1="kapłanem", K1="kapłanie", W1="Kapłanie", M2="Kapłanka", D2="kapłanki", C2="kapłance", B2="kapłankę", N2="kapłanką", K2="kapłance", W2="Kapłanko" },
      ["Rogue"] = { M1="Łotrzyk", D1="łotrzyka", C1="łotrzykowi", B1="łotrzyka", N1="łotrzykiem", K1="łotrzyku", W1="Łotrzyku", M2="Łotrzyca", D2="łotrzycy", C2="łotrzycy", B2="łotrzycę", N2="łotrzycą", K2="łotrzycy", W2="Łotrzyco" },
      ["Shaman"] = { M1="Szaman", D1="szamana", C1="szamanowi", B1="szamana", N1="szamanem", K1="szamanie", W1="Szamanie", M2="Szamanka", D2="szamanki", C2="szamance", B2="szamankę", N2="szamanką", K2="szamance", W2="Szamanko" },
      ["Warlock"] = { M1="Czarnoksiężnik", D1="czarnoksiężnika", C1="czarnoksiężnikowi", B1="czarnoksiężnika", N1="czarnoksiężnikiem", K1="czarnoksiężniku", W1="Czarnoksiężniku", M2="Czarownica", D2="czarownicy", C2="czarownicy", B2="czarownicę", N2="czarownicą", K2="czarownicy", W2="Czarownico" },
      ["Warrior"] = { M1="Wojownik", D1="wojownika", C1="wojownikowi", B1="wojownika", N1="wojownikiem", K1="wojowniku", W1="Wojowniku", M2="Wojowniczka", D2="wojowniczki", C2="wojowniczce", B2="wojowniczkę", N2="wojowniczką", K2="wojowniczce", W2="Wojowniczko" }, }
if (p_race[MF_race]) then      
   player_race = { M1=p_race[MF_race].M1, D1=p_race[MF_race].D1, C1=p_race[MF_race].C1, B1=p_race[MF_race].B1, N1=p_race[MF_race].N1, K1=p_race[MF_race].K1, W1=p_race[MF_race].W1, M2=p_race[MF_race].M2, D2=p_race[MF_race].D2, C2=p_race[MF_race].C2, B2=p_race[MF_race].B2, N2=p_race[MF_race].N2, K2=p_race[MF_race].K2, W2=p_race[MF_race].W2 };
else   
   player_race = { M1=MF_race, D1=MF_race, C1=MF_race, B1=MF_race, N1=MF_race, K1=MF_race, W1=MF_race, M2=MF_race, D2=MF_race, C2=MF_race, B2=MF_race, N2=MF_race, K2=MF_race, W2=MF_race };
end
if (p_class[MF_class]) then
   player_class = { M1=p_class[MF_class].M1, D1=p_class[MF_class].D1, C1=p_class[MF_class].C1, B1=p_class[MF_class].B1, N1=p_class[MF_class].N1, K1=p_class[MF_class].K1, W1=p_class[MF_class].W1, M2=p_class[MF_class].M2, D2=p_class[MF_class].D2, C2=p_class[MF_class].C2, B2=p_class[MF_class].B2, N2=p_class[MF_class].N2, K2=p_class[MF_class].K2, W2=p_class[MF_class].W2 };
else
   player_class = { M1=MF_class, D1=MF_class, C1=MF_class, B1=MF_class, N1=MF_class, K1=MF_class, W1=MF_class, M2=MF_class, D2=MF_class, C2=MF_class, B2=MF_class, N2=MF_class, K2=MF_class, W2=MF_class };
end


local function StringHash(text)           -- funkcja tworząca Hash (32-bitowa liczba) podanego tekstu
  text = string.gsub(text, "$N$", "");
  text = string.gsub(text, "$N", "");
  text = string.gsub(text, "$R", "");
  text = string.gsub(text, "$C", "");
  local counter = 1;
  local pomoc = 0;
  local dlug = string.len(text);
  for i = 1, dlug, 3 do 
    counter = math.fmod(counter*8161, 4294967279);  -- 2^32 - 17: Prime!
    pomoc = (string.byte(text,i)*16776193);
    counter = counter + pomoc;
    pomoc = ((string.byte(text,i+1) or (dlug-i+256))*8372226);
    counter = counter + pomoc;
    pomoc = ((string.byte(text,i+2) or (dlug-i+256))*3932164);
    counter = counter + pomoc;
  end
  return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end


function RenderujKody(txt)
   txt = string.gsub(txt, UnitName("player"), "$N");
   txt = string.gsub(txt, string.upper(UnitName("player")), "$N$");
   txt = string.gsub(txt, UnitRace("player"), "$R");
   txt = string.gsub(txt, string.lower(UnitRace("player")), "$R");
   txt = string.gsub(txt, UnitClass("player"), "$C");
   txt = string.gsub(txt, string.lower(UnitClass("player")), "$C");
   return txt;
end


function MF_OnEvent(self, event, ...)
   if (event=="PLAY_MOVIE") then
      MF_movieID = ... ;
      if (MF_movieID) then
         print("MF-uruchamiam movie ID="..MF_movieID);      
--         MovieFrame.CloseDialog:SetText("Czy na pewno chcesz przerwać wyświetlanie tego filmu?");
         if (MF_pytanie1 == nil) then
            MF_pytanie1 = MovieFrame.CloseDialog:CreateFontString(nil, "ARTWORK");
            MF_pytanie1:SetFontObject(GameFontNormal);
            MF_pytanie1:SetJustifyH("CENTER");
            MF_pytanie1:SetJustifyV("CENTER");
            MF_pytanie1:ClearAllPoints();
            MF_pytanie1:SetPoint("CENTER", MovieFrame.CloseDialog, "CENTER", 0, 6);
            MF_pytanie1:SetFont(MF_Font, 13);
            MF_pytanie1:SetText("Czy chcesz przerwać wyświetlanie filmu?");
         end
         MovieFrame.CloseDialog.ConfirmButton:SetText("Tak");
         MovieFrame.CloseDialog.ResumeButton:SetText("Nie");
         MovieFrame:EnableSubtitles(true);      -- włącz wyświetlanie napisów
         MF_last_ST = "";
         MF_lp = 0;
         MF_ID = tostring(MF_movieID);
         while (string.len(MF_ID)<3) do
            MF_ID = "0"..MF_ID;
         end
         local _font, _size, _3 = MovieFrameSubtitleString:GetFont();
         MovieFrameSubtitleString:SetFont(MF_Font, _size);           -- polskie czcionki do napisów
         MovieFrame:HookScript("OnMovieShowSubtitle", MF_ShowMovieSubtitles);
      end
   elseif (event=="CINEMATIC_START") then
      print("MF-uruchamiam cinematic");
--      CinematicFrameCloseDialog:SetText("Czy na pewno chcesz przerwać wyświetlanie tego filmu?");
      if (MF_pytanie2 == nil) then
         MF_pytanie2 = CinematicFrameCloseDialog:CreateFontString(nil, "ARTWORK");
         MF_pytanie2:SetFontObject(GameFontNormal);
         MF_pytanie2:SetJustifyH("CENTER");
         MF_pytanie2:SetJustifyV("CENTER");
         MF_pytanie2:ClearAllPoints();
         MF_pytanie2:SetPoint("CENTER", CinematicFrameCloseDialog, "CENTER", 0, 6);
         MF_pytanie2:SetFont(MF_Font, 13);
         MF_pytanie2:SetText("Czy chcesz przerwać wyświetlanie filmu?");
      end
      CinematicFrameCloseDialogConfirmButton:SetText("Tak");
      CinematicFrameCloseDialogResumeButton:SetText("Nie");
      if (((UnitLevel("player")==1) and (C_Map.GetBestMapForUnit("player")~=1409) and (C_Map.GetBestMapForUnit("player")~=1726) and (C_Map.GetBestMapForUnit("player")~=1727)) or ((MF_class == "Death Knight") and (UnitLevel("player")==55))) then
         MF_SubTitle = CinematicFrame:CreateFontString(nil, "ARTWORK");    -- mamy Cinematic INTRO
         MF_SubTitle:SetFontObject(GameFontNormalLarge);
         MF_SubTitle:SetJustifyH("CENTER"); 
         MF_SubTitle:SetJustifyV("MIDDLE");
         MF_SubTitle:ClearAllPoints();
         MF_SubTitle:SetPoint("CENTER", CinematicFrame, "BOTTOM", 0, 65);
         MF_SubTitle:SetText("");
         MF_SubTitle:SetFont(MF_Font, 22);
         MF_playing = false;
         MF_lp = 1;
         MF_showing = false;
         if (MF_Data[MF_race..":01"]) then
            MF_sub1 = MF_Data[MF_race..":01"]["START"];
            MF_sub2 = MF_Data[MF_race..":01"]["STOP"];
            MF_sub3 = MF_Data[MF_race..":01"]["NAPIS"];
            CinematicFrame:HookScript("OnUpdate", MF_ShowCinematicIntro);
         end
      else                                      -- mamy cinematic on game
         CinematicFrame:HookScript("OnUpdate", MF_ShowCinematicSubtitles);
         MF_time1 = GetTime();
      end      
   elseif (event=="CINEMATIC_STOP") then
      CinematicFrame:SetScript("OnUpdate", nil);
      -- wyłącz napisy
      if (MF_SubTitle) then
         MF_SubTitle:Hide();
      end
   end
end


function MF_ShowMovieSubtitles()       -- wyświetlanie napisów w MOVIES
   local MF_readed_ST = MovieFrameSubtitleString:GetText();
   if (MF_readed_ST ~= MF_last_ST) then      -- napis jest inny niż ostatni
      MF_lp = MF_lp + 1;
      local MF_lpSTR = tostring(MF_lp);
      if (MF_lp<10) then
         MF_lpSTR = "0"..MF_lpSTR;
      end
      MF_last_ST = MF_readed_ST;             -- zapisz jako ostatni napis
      local MF_brak_NR = true;
      if (MF_Data[MF_ID..":"..MF_lpSTR]) then      -- jest w bazie tłumaczenie napisu nr MF_lp
         if (MF_debug) then
            MF_PZ[MF_ID..":"..MF_lpSTR] = MF_readed_ST.."#"..MF_Data[MF_ID..":"..MF_lpSTR]["NAPIS"];
         end
         local _font, _size, _3 = MovieFrameSubtitleString:GetFont();   -- odczytaj wielkość czcionki
         if (MF_Data[MF_ID..":"..MF_lpSTR] and MF_Data[MF_ID..":"..MF_lpSTR]["ORYG"]==MF_readed_ST) then   -- zgadza się tekst angielski
            MovieFrameSubtitleString:SetText(MF_ZmienKody(MF_Data[MF_ID..":"..MF_lpSTR]["NAPIS"]));
            MovieFrameSubtitleString:SetFont(MF_Font, _size); 
            MF_brak_NR = false;
         else        -- kolejność jest zaburzona - poszukaj ORYG w tym ID
            local ii = 1;
            local ii_STR = tostring(ii);
            if (ii<10) then
               ii_STR = "0"..tostring(ii);
            end
            while (MF_Data[MF_ID..":"..ii_STR] and MF_Data[MF_ID..":"..ii_STR]["ORYG"]) do
               if (MF_Data[MF_ID..":"..ii_STR]["ORYG"]==MF_readed_ST) then   -- zgadza się tekst angielski
                  MovieFrameSubtitleString:SetText(MF_ZmienKody(MF_Data[MF_ID..":"..ii_STR]["NAPIS"]));
                  MovieFrameSubtitleString:SetFont(MF_Font, _size); 
                  MF_brak_NR = false;
                  MF_lp = ii;
                  break;
               end
               ii = ii + 1;
               ii_STR = tostring(ii);
               if (ii<10) then
                  ii_STR = "0"..tostring(ii);
               end
            end
         end
      else           -- nie ma tego NR, ale przeszukaj oryginały, może znajdziesz
         local _font, _size, _3 = MovieFrameSubtitleString:GetFont();   -- odczytaj wielkość czcionki
         local ii = 1;
         local ii_STR = tostring(ii);
         if (ii<10) then
            ii_STR = "0"..tostring(ii);
         end
         while (MF_Data[MF_ID..":"..ii_STR] and MF_Data[MF_ID..":"..ii_STR]["ORYG"]) do
            if (MF_Data[MF_ID..":"..ii_STR]["ORYG"]==MF_readed_ST) then   -- zgadza się tekst angielski
               MovieFrameSubtitleString:SetText(MF_ZmienKody(MF_Data[MF_ID..":"..ii_STR]["NAPIS"]));
               MovieFrameSubtitleString:SetFont(MF_Font, _size); 
               MF_brak_NR = false;
               MF_lp = ii;
               break;
            end
            ii = ii + 1;
            ii_STR = tostring(ii);
            if (ii<10) then
               ii_STR = "0"..tostring(ii);
            end
         end
      end
      if (MF_brak_NR) then
         MF_PS[MF_ID..":"..MF_lpSTR] = MF_readed_ST;
      end
   end
end


function MF_ShowCinematicSubtitles()            -- wyświetlanie napisów w CINEMATIC
   if (GetTime() - MF_time1 > 0.25) then        -- minęło conajmniej 0.25 sek.
      if (CinematicFrame.Subtitle1 and CinematicFrame.Subtitle1:IsVisible()) then        -- jest widoczny napis
         local MF_napis = CinematicFrame.Subtitle1:GetText();     -- odczytaj napis angielski
         if (MF_napis and (string.len(MF_napis)>0) and (string.find(MF_napis,"@")==nil)) then  -- znak '@' wskazuje na tekst polski
            MF_time1 = GetTime() + 1;                             -- +1 sek. nie trzeba sprawdzać
            local MF_zapisz_EN = true;
            MF_napis = RenderujKody(MF_napis);                    -- przeszukaj tekst i zamien na kody $x
            local MF_hash = StringHash(MF_napis);                 -- zrób Hash z tego tekstu
            local p1, p2 = string.find(MF_napis,":");             -- poszukaj znaku ':'
            if (p1 and (p1>0) and (p1<30)) then         -- jest znak ':' w początkowej części napisu (NPC says:)
               local MF_napis2 = RenderujKody(string.sub(MF_napis, p1+2));
               local MF_hash2 = StringHash(MF_napis2);
               if (BB_Bubbles[MF_hash2]) then            -- istnieje tłumaczenie w dymkach
                  local MF_output = string.sub(MF_napis,1,p1-1).." mówi: "..MF_ZmienKody(BB_Bubbles[MF_hash2].."@");
                  local _font, _size, _3 = CinematicFrame.Subtitle1:GetFont();   -- odczytaj wielkość czcionki
                  CinematicFrame.Subtitle1:SetText(MF_output);                   -- podmień wyświetlany tekst
                  CinematicFrame.Subtitle1:SetFont(MF_Font, _size);              -- zmień czcionkę na polską
                  MF_zapisz_EN = false;
               else
                  if (MF_zapisz_EN) then             -- zapisz oryginalny tekst wraz z kodem Hash
                     MF_PS[tostring(MF_hash)] = MF_napis;       
                  end
               end
            else
               if (BB_Bubbles[MF_hash]) then            -- istnieje tłumaczenie w dymkach
                  local MF_tekst = MF_ZmienKody(BB_Bubbles[MF_hash]);
                  if (strsub(MF_tekst,1,2)=="%o") then 
                     MF_tekst = strsub(MF_tekst, 3):gsub("^%s*", "");
                  end
                  local MF_output = MF_tekst.."@";
                  local _font, _size, _3 = CinematicFrame.Subtitle1:GetFont();   -- odczytaj wielkość czcionki
                  CinematicFrame.Subtitle1:SetText(MF_output);                   -- podmień wyświetlany tekst
                  CinematicFrame.Subtitle1:SetFont(MF_Font, _size);              -- zmień czcionkę na polską
                  MF_zapisz_EN = false;
               else
                  if (MF_zapisz_EN) then             -- zapisz oryginalny tekst wraz z kodem Hash
                     MF_PS[tostring(MF_hash)] = MF_napis;       
                  end
               end
            end
         end
      end
   end
end


function MF_ShowCinematicIntro()    -- wyświetlanie własnych napisów w INTRO
   if (MF_playing==false) then         
      MF_timer = GetTime();         -- wystartuj zegar filmu
      MF_playing=true;
   end
   if ((MF_showing==false) and (GetTime() > (MF_timer + MF_sub1))) then      -- czas wystartować napis
      MF_SubTitle:SetText(MF_sub3);
      MF_showing=true;
   end      
   if ((MF_showing==true) and (GetTime() > (MF_timer + MF_sub2))) then       -- czas zatrzymać napis
      MF_SubTitle:SetText("");
      -- ładuj następny
      MF_showing=false;
      MF_lp = MF_lp + 1;
      local MF_lpSTR = tostring(MF_lp);
      if (MF_lp<10) then
         MF_lpSTR = "0"..MF_lpSTR;
      end
      if (MF_Data[MF_race..":"..MF_lpSTR]) then
         MF_sub1 = MF_Data[MF_race..":"..MF_lpSTR]["START"];
         MF_sub2 = MF_Data[MF_race..":"..MF_lpSTR]["STOP"];
         MF_sub3 = MF_ZmienKody(MF_Data[MF_race..":"..MF_lpSTR]["NAPIS"]);
      else
         MF_sub1=1000;
         MF_sub2=1000;
      end
   end          
end


function MF_ZmienKody(message)
   message = string.gsub(message, "$n$", string.upper(MF_name));    -- i trzeba ją zamienić na nazwę gracza
   message = string.gsub(message, "$N$", string.upper(MF_name));    -- tu jeszcze pisane DUŻYMI LITERAMI
   message = string.gsub(message, "$n", MF_name);
   message = string.gsub(message, "$N", MF_name);
   message = string.gsub(message, "$g", "$G");     -- obsługa kodu $g(m;ż)
   local MF_forma = "";
   local nr_1, nr_2, nr_3 = 0;
   local nr_poz = string.find(message, "$G");    -- gdy nie znalazł, jest: nil; liczy od 1
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      while (string.sub(message, nr_1, nr_1) ~= "(") do   -- szukaj nawiasu otwierającego
         nr_1 = nr_1 + 1;
      end
      if (string.sub(message, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while (string.sub(message, nr_2, nr_2) ~= ";") do   -- szukaj średnika oddzielającego
            nr_2 = nr_2 + 1;
         end
         if (string.sub(message, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while (string.sub(message, nr_3, nr_3) ~= ")") do   -- szukaj nawiasu zamykającego
               nr_3 = nr_3 + 1;
            end
            if (string.sub(message, nr_3, nr_3) == ")") then
               if (MF_sex==3) then         -- wypowiedzi wyświetlaj w formie żeńskiej
                  MF_forma = string.sub(message,nr_2+1,nr_3-1);
               else                                -- wypowiedzi wyświetlaj w formie męskiej
                  MF_forma = string.sub(message,nr_1+1,nr_2-1);
               end
               message = string.sub(message,1,nr_poz-1) .. MF_forma .. string.sub(message,nr_3+1);
            end   
         end
      end
      nr_poz = string.find(message, "$G");
   end
   
   message = string.gsub(message, "$r", "$R");  
   message = string.gsub(message, "$c", "$C");    
   if (MF_sex==3) then       -- gracz gra kobietą
      message = string.gsub(message, "$R1", player_race.M2);
      message = string.gsub(message, "$R2", player_race.D2);
      message = string.gsub(message, "$R3", player_race.C2);
      message = string.gsub(message, "$R4", player_race.B2);
      message = string.gsub(message, "$R5", player_race.N2);
      message = string.gsub(message, "$R6", player_race.K2);
      message = string.gsub(message, "$R7", player_race.W2);
      message = string.gsub(message, "$R", player_race.M2);
      message = string.gsub(message, "$C1", player_class.M2);
      message = string.gsub(message, "$C2", player_class.D2);
      message = string.gsub(message, "$C3", player_class.C2);
      message = string.gsub(message, "$C4", player_class.B2);
      message = string.gsub(message, "$C5", player_class.N2);
      message = string.gsub(message, "$C6", player_class.K2);
      message = string.gsub(message, "$C7", player_class.W2);
      message = string.gsub(message, "$C", player_class.M2);
   else                          -- gracz gra facetem
      message = string.gsub(message, "$R1", player_race.M1);
      message = string.gsub(message, "$R2", player_race.D1);
      message = string.gsub(message, "$R3", player_race.C1);
      message = string.gsub(message, "$R4", player_race.B1);
      message = string.gsub(message, "$R5", player_race.N1);
      message = string.gsub(message, "$R6", player_race.K1);
      message = string.gsub(message, "$R7", player_race.W1);
      message = string.gsub(message, "$R", player_race.M1);
      message = string.gsub(message, "$C1", player_class.M1);
      message = string.gsub(message, "$C2", player_class.D1);
      message = string.gsub(message, "$C3", player_class.C1);
      message = string.gsub(message, "$C4", player_class.B1);
      message = string.gsub(message, "$C5", player_class.N1);
      message = string.gsub(message, "$C6", player_class.K1);
      message = string.gsub(message, "$C7", player_class.W1);
      message = string.gsub(message, "$C", player_class.M1);
   end

   return message;   
end


MF_Frame = CreateFrame("Frame");
MF_Frame:SetScript("OnEvent", MF_OnEvent);
MF_Frame:RegisterEvent("PLAY_MOVIE");
MF_Frame:RegisterEvent("CINEMATIC_START");
MF_Frame:RegisterEvent("CINEMATIC_STOP");
if (not MF_PS) then
   MF_PS = {};
end

DEFAULT_CHAT_FRAME:AddMessage("|cffffff00WoWpoPolsku-Movies ver. "..MF_version.." - uruchomiono");
