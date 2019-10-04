-- Addon: WoWpoPolsku-BB (version: 8.08) 2019.08.10
-- Description: AddOn displays translated Bubbled of NPC.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- WWW: https://wowpopolsku.pl

local BB_version = GetAddOnMetadata("WoWpoPolsku_Bubbles", "Version");
local BB_ctrFrame = CreateFrame("FRAME", "WoWpoPolsku-BubblesFrame");
local BB_Font = "Interface\\AddOns\\WoWpoPolsku_Bubbles\\Fonts\\frizquadratatt_pl.ttf";
local BB_name;
local BB_class;
local BB_race;
local BB_BubblesArray = {};
local p_race = {};
local p_class = {};
local player_race = {};
local player_class = {};
local BB_TRvisible= 0;
local BB_Zatrzask = 0;
local BB_name_NPC = "";
local BB_hash_Code= "";
local BB_bufor = {};
local BB_gotowe= {};
local BB_ile_got = 0;
local Y_Race1=UnitRace("player");
local Y_Race2=string.lower(UnitRace("player"));
local Y_Race3=string.upper(UnitRace("player"));
local Y_Class1=UnitClass("player");
local Y_Class2=string.lower(UnitClass("player"));
local Y_Class3=string.upper(UnitClass("player"));


local function StringHash(text)           -- funkcja tworząca Hash (32-bitowa liczba) podanego tekstu
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


local function BB_bubblizeText()
  for i = 1, WorldFrame:GetNumChildren() do                -- przeszukaj ramki potomne na WorldFrame
     local child = select(i, WorldFrame:GetChildren());    -- jest ramka "dziecko"
     if not child:IsForbidden() then                       -- czy ramka nie jest zabroniona?
        for j = 1, child:GetNumRegions() do                   -- przeszukaj regiony, gdzie występuje na ekranie
           region = select(j, child:GetRegions());            -- jest region
           for idx, iArray in ipairs(BB_BubblesArray) do      -- sprawdź, czy dane są właściwe (tekst oryg. się zgadza z zapisaną w tablicy)
              if region and not region:GetName() and region:IsVisible() and region.GetText and region:GetText() == iArray[1] then
                 local oldTextWidth = region:GetStringWidth() -- dotychczasowa szerokość okna dymku
                 region:SetText(iArray[2]);                   -- wpisz tu nasze tłumaczenie
                 local _font1, _size1, _3 = region:GetFont(); -- odczytaj aktualną czcionkę i rozmiar
                 region:SetFont(BB_Font, _size1);             -- ustaw polską czcionkę oraz niezmienioną wielkość (13)
                 region:SetWidth(region:GetWidth()+(region:GetStringWidth() - oldTextWidth));  -- określ nową szer. okna
                 tremove(BB_BubblesArray, idx);               -- usuń zapamiętane dane z tablicy
              end
           end
        end
     end
  end
  for idx, iArray in ipairs(BB_BubblesArray) do            -- przeszukaj jeszcze raz tablicę
     if (iArray[3] >= 100) then                            -- licznik osiągnął 100
        tremove(BB_BubblesArray, idx);                     -- usuń zapamiętane dane z tablicy
     else
        iArray[3] = iArray[3]+1;                           -- zwiększ licznik (nie pokazał się dymek?)
     end;
  end;
  if (#(BB_BubblesArray) == 0) then
     BB_ctrFrame:SetScript("OnUpdate", nil);               -- wyłącz metodę Update, bo tablica pusta
  end;
end;


local function ChatFilter(self, event, arg1, arg2, arg3, _, arg5, ...)     -- wywoływana, gdy na chat ma pojawić się tekst od NPC
   local changeBubble = false;
   local colorText = "";
   local original_txt = strtrim(arg1);
   local name_NPC = string.gsub(arg2, " says:", "");
   local target = arg5;
	
   if (event == "CHAT_MSG_MONSTER_SAY") then          -- określ kolor tekstu do okna chat
      colorText = "|cFFFFFF9F";
      if (GetCVar("ChatBubbles")) then
         changeBubble = true;
      end
   elseif (event == "CHAT_MSG_MONSTER_PARTY") then
      colorText = "|cFFAAAAFF";
   elseif (event == "CHAT_MSG_MONSTER_YELL") then
      colorText = "|cFFFF4040";
      if (GetCVar("ChatBubbles")) then
         changeBubble = true;
      end
   elseif (event == "CHAT_MSG_MONSTER_WHISPER") then
      colorText = "|cFFFFB5EB";
   elseif (event == "CHAT_MSG_MONSTER_EMOTE") then
      colorText = "|cFFFF8040";
   end

   BB_is_translation="0";      
   if (BB_PM["active"] == "1") then                       -- dodatek aktywny - szukaj tłumaczenia
      if (arg5 ~= "") then
         original_txt = string.gsub(original_txt, arg5, "");        -- usuń osobę ($target) z tekstu oryginalnego
      end
      original_txt = string.gsub(original_txt, Y_Race1, "");        -- usuń rasę z tekstu
      original_txt = string.gsub(original_txt, Y_Race2, "");
      original_txt = string.gsub(original_txt, Y_Race3, "");
      original_txt = string.gsub(original_txt, Y_Class1, "");       -- usuń klasę z tekstu
      original_txt = string.gsub(original_txt, Y_Class2, "");
      original_txt = string.gsub(original_txt, Y_Class3, "");
      local HashCode = StringHash(original_txt);
      if (BB_Bubbles[HashCode]) then         -- jest tłumaczenie polskie
         newMessage = BB_Bubbles[HashCode];
         if (arg5 ~= "") then                             -- może być zmienna $target w tłumaczeniu
            newMessage = string.gsub(newMessage, "$n$", string.upper(arg5));    -- i trzeba ją zamienić na nazwę gracza
            newMessage = string.gsub(newMessage, "$N$", string.upper(arg5));    -- tu jeszcze pisane DUŻYMI LITERAMI
            newMessage = string.gsub(newMessage, "$n", arg5);    
            newMessage = string.gsub(newMessage, "$N", arg5);    
            newMessage = string.gsub(newMessage, "$target", arg5);    
            newMessage = string.gsub(newMessage, "$TARGET", arg5);    
         end
         newMessage = string.gsub(newMessage, "$c", player_class.W);    
         newMessage = string.gsub(newMessage, "$C", player_class.W);    
         newMessage = string.gsub(newMessage, "$r", player_race.W);    
         newMessage = string.gsub(newMessage, "$R", player_race.W);    
         BB_is_translation="1";      
         nr_poz=BB_FindProS(newMessage,1);
         if (BB_PM["chat-pl"] == "1") then                -- wyświetlaj tłumaczenie w linii czatu
            if (nr_poz>0) then           -- mamy formę opisową dymku %s np. NPC_name wpada w szał!
               if (nr_poz==1) then
                  newMessage = name_NPC..strsub(newMessage, 3);
               else
                  newMessage = strsub(newMessage,1,nr_poz-1)..name_NPC..strsub(newMessage, nr_poz+2);
               end
               DEFAULT_CHAT_FRAME:AddMessage(colorText..newMessage);
            elseif (strsub(newMessage,1,2)=="%o") then         -- jest forma '%o'
               newMessage = strsub(newMessage, 3);
               DEFAULT_CHAT_FRAME:AddMessage(colorText..newMessage:gsub("^%s*", "")); -- usuń białe spacje na początku
            else
               DEFAULT_CHAT_FRAME:AddMessage(colorText..name_NPC.." mówi: "..newMessage);
            end
         else   
            if (nr_poz>0) then        -- mamy formę opisową dymku np. NPC_name coś robi.
               if (nr_poz==1) then
                  newMessage = name_NPC..strsub(newMessage, 3);
               else
                  newMessage = strsub(newMessage,1,nr_poz-1)..name_NPC..strsub(newMessage, nr_poz+2);
               end
            elseif (strsub(newMessage,1,2)=="%o") then         -- jest forma '%o'
               newMessage = strsub(newMessage, 3);
            end
         end
         if (changeBubble) then                          -- wyświetlaj dymek po polsku (jeśli istnieje)
            tinsert(BB_BubblesArray, { [1] = arg1, [2] = newMessage, [3] = 1 });
            BB_ctrFrame:SetScript("OnUpdate", BB_bubblizeText);
         end
      else                                               -- nie mamy tłumaczenia
         if (BB_PM["saveNB"] == "1") then                -- zapisz oryginalny tekst
            original_txt = strtrim(arg1);
            BB_PS[name_NPC..":"..tostring(HashCode)] = original_txt.."@"..target;
         end
         if (BB_PM["TRonline"] == "1") then              -- tłumaczenie online
            local pomoc = name_NPC.."@"..tostring(HashCode).."@"..original_txt;
            local jest = 0;
            for ind=1,BB_ile_got,1 do             -- sprawdź czy taki dymek jest już w gotowych
               if (BB_gotowe[ind] == pomoc) then
                  jest = 1;
               end
            end
            if (jest == 0) then
               if (BB_Zatrzask == 0) then                   -- bufor pusty
                  BB_Input1:SetText(original_txt);
                  BB_Input2:SetText("");
                  BB_Zatrzask = 1;
                  BB_ButtonZatrz:SetText("X");
                  BB_name_NPC = name_NPC;
                  BB_hash_Code= tostring(HashCode);
                  BB_bufor[BB_Zatrzask] = name_NPC.."@"..tostring(HashCode).."@"..original_txt;
               else
                  for ind=1,BB_Zatrzask,1 do             -- sprawdź czy jest już taki dymek w buforze
                     if (BB_bufor[ind] == pomoc) then
                        jest = 1;
                     end
                  end
                  if (jest == 0) then        -- nie ma jeszcze w buforze
                     BB_Zatrzask = BB_Zatrzask + 1;
                     BB_bufor[BB_Zatrzask] = pomoc;
                     BB_ButtonZatrz:SetText(tostring(BB_Zatrzask));
                  end
               end
            end
         end
      end
   end

   if ((BB_PM["chat-en"] == "1") or (BB_is_translation ~= "1")) then     -- gdy nie ma także tłumaczenia                 
      return false;     -- wyświetlaj tekst oryginalny w oknie czatu
   else
      return true;      -- nie wyświetla oryginalnego tekstu
   end   
   
end


function BB_FindProS(text)                 -- znajdź, czy jest tekst '%s' w podanym tłumaczeniu
   local dl_txt = string.len(text)-1;
   for i_j=1,dl_txt,1 do
      if (strsub(text,i_j,i_j+1)=="%s") then       
         return i_j;
      end
   end
   return 0;
end


function BB_CheckVars()
  if (not BB_PM) then
     BB_PM = {};
  end
  if (not BB_PS) then
     BB_PS = {};
  end
  if (not BB_TR) then
     BB_TR = {};
  end
  -- initialize check options
  if (not BB_PM["active"] ) then    -- dodatek aktywny
     BB_PM["active"] = "1";   
  end
  if (not BB_PM["chat-en"] ) then   -- pokaż tekst angielski w oknie czatu
     BB_PM["chat-en"] = "0";   
  end
  if (not BB_PM["chat-pl"] ) then   -- pokaż tekst polski w oknie czatu
     BB_PM["chat-pl"] = "1";   
  end
  if (not BB_PM["saveNB"] ) then    -- zapisz nieprzetłumaczone dymki
     BB_PM["saveNB"] = "1";   
  end
  if (not BB_PM["setsize"] ) then   -- uaktywnij zmiany wielkości czcionki
     BB_PM["setsize"] = "0";   
  end
  if (not BB_PM["fontsize"] ) then  -- wielkość czcionki
     BB_PM["fontsize"] = "13";   
  end
  if (not BB_PM["TRonline"] ) then  -- przycisk okna tłumaczenia on-line
     BB_PM["TRonline"] = "0";   
  end
end
  

function BB_SetCheckButtonState()
  BBCheckButton1:SetChecked(BB_PM["active"]=="1");
  BBCheckButton2:SetChecked(BB_PM["chat-en"]=="1");
  BBCheckButton3:SetChecked(BB_PM["chat-pl"]=="1");
  BBCheckButton5:SetChecked(BB_PM["saveNB"]=="1");
  BBCheckButton8:SetChecked(BB_PM["TRonline"]=="1");
  BBCheckSize:SetChecked(BB_PM["setsize"]=="1");
  local fontsize = tonumber(BB_PM["fontsize"]);
  BBslider:SetValue(fontsize);
  if (BB_PM["setsize"]=="1") then
     BBOpis1:SetFont(BB_Font, fontsize);
  else   
     BBOpis1:SetFont(BB_Font, 13);
  end
end


function BB_BlizzardOptions()

-- Create main frame for information text
local BBOptions = CreateFrame("FRAME", "WoWpoPolskuBubblesOptions");
BBOptions.refresh = function (self) BB_SetCheckButtonState() end;
BBOptions.name = "WoWpoPolsku-Bubbles";
InterfaceOptions_AddCategory(BBOptions);

local BBOptionsHeader = BBOptions:CreateFontString(nil, "ARTWORK");
BBOptionsHeader:SetFontObject(GameFontNormalLarge);
BBOptionsHeader:SetJustifyH("LEFT"); 
BBOptionsHeader:SetJustifyV("TOP");
BBOptionsHeader:ClearAllPoints();
BBOptionsHeader:SetPoint("TOPLEFT", 16, -16);
BBOptionsHeader:SetText("WoWpoPolsku-Bubbless, ver. "..BB_version.." ("..BB_base..") by Platine © 2019");

local BBOptionsDate = BBOptions:CreateFontString(nil, "ARTWORK");
BBOptionsDate:SetFontObject(GameFontNormalLarge);
BBOptionsDate:SetJustifyH("LEFT"); 
BBOptionsDate:SetJustifyV("TOP");
BBOptionsDate:ClearAllPoints();
BBOptionsDate:SetPoint("TOPRIGHT", BBOptionsHeader, "TOPRIGHT", 0, -22);
BBOptionsDate:SetText("Data bazy tłumaczeń: "..BB_date);
BBOptionsDate:SetFont(BB_Font, 16);

local BBCheckButton1 = CreateFrame("CheckButton", "BBCheckButton1", BBOptions, "OptionsCheckButtonTemplate");
BBCheckButton1:SetPoint("TOPLEFT", BBOptionsHeader, "BOTTOMLEFT", 0, -30);
BBCheckButton1:SetScript("OnClick", function(self) if (BB_PM["active"]=="1") then BB_PM["active"]="0" else BB_PM["active"]="1" end; end);
BBCheckButton1Text:SetText("dodatek aktywny");     -- dodatek aktywny
BBCheckButton1Text:SetFont(BB_Font, 13);

local BBCheckButton2 = CreateFrame("CheckButton", "BBCheckButton2", BBOptions, "OptionsCheckButtonTemplate");
BBCheckButton2:SetPoint("TOPLEFT", BBCheckButton1, "BOTTOMLEFT", 0, -5);
BBCheckButton2:SetScript("OnClick", function(self) if (BB_PM["chat-en"]=="1") then BB_PM["chat-en"]="0" else BB_PM["chat-en"]="1" end; end);
BBCheckButton2Text:SetText("wyświetlaj tekst oryginalny w oknie czatu");
BBCheckButton2Text:SetFont(BB_Font, 13);

local BBCheckButton3 = CreateFrame("CheckButton", "BBCheckButton3", BBOptions, "OptionsCheckButtonTemplate");
BBCheckButton3:SetPoint("TOPLEFT", BBCheckButton2, "BOTTOMLEFT", 0, 0);
BBCheckButton3:SetScript("OnClick", function(self) if (BB_PM["chat-pl"]=="1") then BB_PM["chat-pl"]="0" else BB_PM["chat-pl"]="1" end; end);
BBCheckButton3Text:SetText("wyświetlaj tekst tłumaczenia w oknie czatu"); 
BBCheckButton3Text:SetFont(BB_Font, 13);

local BBCheckButton5 = CreateFrame("CheckButton", "BBCheckButton5", BBOptions, "OptionsCheckButtonTemplate");
BBCheckButton5:SetPoint("TOPLEFT", BBCheckButton3, "BOTTOMLEFT", 0, 0);
BBCheckButton5:SetScript("OnClick", function(self) if (BB_PM["saveNB"]=="1") then BB_PM["saveNB"]="0" else BB_PM["saveNB"]="1" end; end);
BBCheckButton5Text:SetText("zapisz nieprzetłumaczone dymki");
BBCheckButton5Text:SetFont(BB_Font, 13);

local BBCheckButton8 = CreateFrame("CheckButton", "BBCheckButton8", BBOptions, "OptionsCheckButtonTemplate");
BBCheckButton8:SetPoint("TOPLEFT", BBCheckButton5, "BOTTOMLEFT", 0, 0);
BBCheckButton8:SetScript("OnClick", function(self) if (BB_PM["TRonline"]=="1") then BB_PM["TRonline"]="0";BB_TRframe:Hide(); else BB_PM["TRonline"]="1";BB_TRframe:Show(); end; end);
BBCheckButton8Text:SetText("pokaż okno tłumaczenia online");
BBCheckButton8Text:SetFont(BB_Font, 13);

local BBCheckSize = CreateFrame("CheckButton", "BBCheckSize", BBOptions, "OptionsCheckButtonTemplate");
BBCheckSize:SetPoint("TOPLEFT", BBCheckButton8, "BOTTOMLEFT", 0, -20);
BBCheckSize:SetScript("OnClick", function(self) if (BB_PM["setsize"]=="1") then BB_PM["setsize"]="0" else BB_PM["setsize"]="1" end; end);
BBCheckSizeText:SetText("uaktywnij funkcję zmiany wielkości czcionki w dymkach (nie zawsze działa)");   
BBCheckSizeText:SetFont(BB_Font, 13);

local BBslider = CreateFrame("Slider", "BBslider", BBOptions, "OptionsSliderTemplate");
BBslider:SetPoint("TOPLEFT", BBCheckSize, "BOTTOMLEFT", 10, -20);
BBslider:SetMinMaxValues(10, 20);
BBslider.minValue, BBslider.maxValue = BBslider:GetMinMaxValues();
BBslider.Low:SetText(BBslider.minValue);
BBslider.High:SetText(BBslider.maxValue);
getglobal(BBslider:GetName() .. 'Text'):SetText('Wielkość czcionki');
getglobal(BBslider:GetName() .. 'Text'):SetFont(BB_Font, 13);
BBslider:SetValue(tonumber(BB_PM["fontsize"]));
BBslider:SetValueStep(1);
BBslider:SetScript("OnValueChanged", function(self,event,arg1) 
                                      BB_PM["fontsize"]=string.format("%d",event); 
                                      BBsliderVal:SetText(BB_PM["fontsize"]);
									           BBOpis1:SetFont(BB_Font, event);
                                      end);
BBsliderVal = BBOptions:CreateFontString(nil, "ARTWORK");
BBsliderVal:SetFontObject(GameFontNormal);
BBsliderVal:SetJustifyH("CENTER");
BBsliderVal:SetJustifyV("TOP");
BBsliderVal:ClearAllPoints();
BBsliderVal:SetPoint("CENTER", BBslider, "CENTER", 0, -12);
BBsliderVal:SetText(BB_PM["fontsize"]);   
BBsliderVal:SetFont(BB_Font, 13);

BBOpis1 = BBOptions:CreateFontString(nil, "ARTWORK");
BBOpis1:SetFontObject(GameFontNormalLarge);
BBOpis1:SetJustifyH("LEFT");
BBOpis1:SetJustifyV("TOP");
BBOpis1:ClearAllPoints();
BBOpis1:SetPoint("TOPLEFT", BBslider, "BOTTOMLEFT", 200, 30);
local fontsize = tonumber(BB_PM["fontsize"]);
if (BB_PM["setsize"]=="1") then
   BBOpis1:SetFont(BB_Font, fontsize);
else
   BBOpis1:SetFont(BB_Font, 13);
end
BBOpis1:SetText("Przykładowy tekst wielkości czcionki");

local IOF_Height = InterfaceOptionsFrame:GetHeight();
   if (IOF_Height>658) then

   local BBText0 = BBOptions:CreateFontString(nil, "ARTWORK");
   BBText0:SetFontObject(GameFontWhite);
   BBText0:SetJustifyH("LEFT");
   BBText0:SetJustifyV("TOP");
   BBText0:ClearAllPoints();
   BBText0:SetPoint("TOPLEFT", BBslider, "BOTTOMLEFT", -5, -40);
   BBText0:SetFont(BB_Font, 13);
   BBText0:SetText("Szybkie komendy z linii czatu");

   local BBText7 = BBOptions:CreateFontString(nil, "ARTWORK");
   BBText7:SetFontObject(GameFontWhite);
   BBText7:SetJustifyH("LEFT");
   BBText7:SetJustifyV("TOP");
   BBText7:ClearAllPoints();
   BBText7:SetPoint("TOPLEFT", BBText0, "BOTTOMLEFT", 0, -10);
   BBText7:SetFont(BB_Font, 13);
   BBText7:SetText("/bbtr   aby wywołać to okno ustawień dodatku");

   local BBText1 = BBOptions:CreateFontString(nil, "ARTWORK");
   BBText1:SetFontObject(GameFontWhite);
   BBText1:SetJustifyH("LEFT");
   BBText1:SetJustifyV("TOP");
   BBText1:ClearAllPoints();
   BBText1:SetPoint("TOPLEFT", BBText7, "BOTTOMLEFT", 0, -10);
   BBText1:SetFont(BB_Font, 13);
   BBText1:SetText("/bbtr 1  lub  /bbtr on   aby aktywować addon");

   local BBText2 = BBOptions:CreateFontString(nil, "ARTWORK");
   BBText2:SetFontObject(GameFontWhite);
   BBText2:SetJustifyH("LEFT");
   BBText2:SetJustifyV("TOP");
   BBText2:ClearAllPoints();
   BBText2:SetPoint("TOPLEFT", BBText1, "BOTTOMLEFT", 0, -4);
   BBText2:SetFont(BB_Font, 13);
   BBText2:SetText("/bbtr 0  lub  /bbtr off   aby deaktywawć addon");

end

local BBWWW1 = BBOptions:CreateFontString(nil, "ARTWORK");
BBWWW1:SetFontObject(GameFontWhite);
BBWWW1:SetJustifyH("LEFT");
BBWWW1:SetJustifyV("TOP");
BBWWW1:ClearAllPoints();
BBWWW1:SetPoint("BOTTOMLEFT", 16, 16);
BBWWW1:SetFont(BB_Font, 13);
BBWWW1:SetText("Odwiedź stronę WWW dodatku:");
  
local BBWWW2 = CreateFrame("EditBox", "BBWWW2", BBOptions, "InputBoxTemplate");
BBWWW2:ClearAllPoints();
BBWWW2:SetPoint("TOPLEFT", BBWWW1, "TOPRIGHT", 10, 4);
BBWWW2:SetHeight(20);
BBWWW2:SetWidth(160);
BBWWW2:SetAutoFocus(false);
BBWWW2:SetFontObject(GameFontGreen);
BBWWW2:SetText("https://wowpopolsku.pl");
BBWWW2:SetCursorPosition(0);
BBWWW2:SetScript("OnEnter", function(self)
   GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
   getglobal("GameTooltipTextLeft1"):SetFont(BB_Font, 13);
   GameTooltip:SetText("kliknij i wciśnij Ctrl+C aby skopiować do schowka", nil, nil, nil, nil, true)
   GameTooltip:Show() --Show the tooltip
   end);
BBWWW2:SetScript("OnLeave", function(self)
   GameTooltip:Hide() --Hide the tooltip
   end);
BBWWW2:SetScript("OnTextChanged", function(self) BBWWW2:SetText("https://wowpopolsku.pl"); end);
end


function BB_SlashCommand(msg)
  -- check the command
  if (msg) then
     local BB_command = string.lower(msg);                -- normalizacja, tylko małe litery
     if ((BB_command=="on") or (BB_command=="1")) then    -- włącz przełącznik aktywności
        BB_PM["active"]="1";
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00WoWpoPolsku-Bubbles jest teraz aktywny");
     elseif ((BB_command=="off") or (BB_command=="0")) then
        BB_PM["active"]="0";
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00WoWpoPolsku-Spells jest teraz nieaktywny");
     else
        InterfaceOptionsFrame_Show();
        InterfaceOptionsFrame_OpenToCategory("WoWpoPolsku-Bubbles");
     end   
  end
end


function BB_ShowTRonline()
   if (BB_TRvisible == 0) then
      BB_TRvisible = 1;
      BB_Button8Save:Show();
      BB_Input1:Show();
      BB_Input2:Show();
      BB_ButtonZatrz:Show();
   else
      BB_TRvisible = 0;
      BB_Button8Save:Hide();
      BB_Input1:Hide();
      BB_Input2:Hide();
      BB_ButtonZatrz:Hide();
   end   
end


function BB_TRzatrzask()                  -- wciśnięto przycisk zwolnienia zatrzasku
   if (BB_Zatrzask > 0) then
      BB_Zatrzask = BB_Zatrzask - 1;
      if (BB_Zatrzask == 0) then
         BB_ButtonZatrz:SetText("O");
      else
         for ind=1,BB_Zatrzask,1 do
            BB_bufor[ind] = BB_bufor[ind+1];
         end
         BB_bufor[BB_Zatrzask+1] = "";
         local p1,p2,p3 = strsplit("@",BB_bufor[1]);
         BB_Input1:SetText(p3);
         if (BB_Zatrzask == 1) then
            BB_ButtonZatrz:SetText("X");
         else
            BB_ButtonZatrz:SetText(tostring(BB_Zatrzask));
         end
      end
   else   
      BB_Input1:SetText("czekam na tekst oryginalny z nieprzetlumaczonego dymku");
   end
   BB_Input2:SetText("");
end
  

function BB_ShowTRsave()
   if (BB_Input2:GetText() == "") then
      BB_Input2:SetText("?? - a gdzie tłumaczenie - ??");
   else
      local p1,p2,p3 = strsplit("@",BB_bufor[1]);
      BB_TR[p1.."@"..p2] = BB_Input1:GetText().."@"..BB_Input2:GetText();
      BB_Input2:SetText("OK - zapisano tłumaczenie - OK");
      BB_Input1:SetText("czekam na tekst oryginalny z nieprzetlumaczonego dymku");
      BB_ile_got = BB_ile_got + 1;
      BB_gotowe[BB_ile_got] = BB_bufor[1];
      BB_TRzatrzask();
   end
end

  
function BB_OknoTRonline()
  BB_TRframe = CreateFrame("Frame","DragFrame1", UIParent);
  BB_TRframe:SetMovable(true);
  BB_TRframe:EnableMouse(true);
  BB_TRframe:RegisterForDrag("LeftButton");
  BB_TRframe:SetScript("OnDragStart", BB_TRframe.StartMoving);
  BB_TRframe:SetScript("OnDragStop", BB_TRframe.StopMovingOrSizing);

  BB_TRframe:SetWidth(500);
  BB_TRframe:SetHeight(46);
  BB_TRframe:ClearAllPoints();
  BB_TRframe:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, 0);
  if (BB_PM["TRonline"] == "1") then
     BB_TRframe:Show();
  else
     BB_TRframe:Hide();
  end;
--local tex = BB_TRframe:CreateTexture("ARTWORK");
--tex:SetAllPoints();
--tex:SetTexture(1.0,0.5,0); tex:SetAlpha(0.5);

  BB_Button8 = CreateFrame("Button",nil, BB_TRframe, "UIPanelButtonTemplate");
  BB_Button8:SetWidth(60);
  BB_Button8:SetHeight(20);
  BB_Button8:SetText("BBTR");
  BB_Button8:ClearAllPoints();
  BB_Button8:SetPoint("TOPLEFT", BB_TRframe, "TOPLEFT", 3, -3);
  BB_Button8:SetScript("OnClick", BB_ShowTRonline);
  if (BB_PM["TRonline"] == "1") then
     BB_Button8:Show();
  end;

  BB_Button8Save = CreateFrame("Button",nil, BB_TRframe, "UIPanelButtonTemplate");
  BB_Button8Save:SetWidth(60);
  BB_Button8Save:SetHeight(20);
  BB_Button8Save:SetText("Zapisz");
  BB_Button8Save:ClearAllPoints();
  BB_Button8Save:SetPoint("TOPLEFT", BB_Button8, "BOTTOMLEFT", 0, 1);
  BB_Button8Save:SetScript("OnClick", BB_ShowTRsave);
  BB_Button8Save:Hide();

  BB_Input1 = CreateFrame("EditBox", "BB_Input1", BB_TRframe, "InputBoxTemplate");
  BB_Input1:ClearAllPoints();
  BB_Input1:SetPoint("TOPLEFT", BB_Button8, "TOPRIGHT", 4, 0);
  BB_Input1:SetHeight(20);
  BB_Input1:SetWidth(400);
  BB_Input1:SetAutoFocus(false);
  BB_Input1:SetFontObject(GameFontGreen);
  BB_Input1:SetText("tutaj bedzie tekst oryginalny");
  BB_Input1:SetCursorPosition(0);
  BB_Input1:Hide();
  
  BB_Input2 = CreateFrame("EditBox", "BB_Input2", BB_TRframe, "InputBoxTemplate");
  BB_Input2:ClearAllPoints();
  BB_Input2:SetPoint("TOPLEFT", BB_Button8Save, "TOPRIGHT", 4, 0);
  BB_Input2:SetHeight(20);
  BB_Input2:SetWidth(400);
  BB_Input2:SetAutoFocus(false);
  BB_Input2:SetFontObject(GameFontWhite);
  BB_Input2:SetText("a tutaj będzie polskie tłumaczenie");
  BB_Input2:SetFont(BB_Font, 12);
  BB_Input2:SetCursorPosition(0);
  BB_Input2:Hide();
  
  BB_ButtonZatrz = CreateFrame("Button",nil, BB_TRframe, "UIPanelButtonTemplate");
  BB_ButtonZatrz:SetWidth(30);
  BB_ButtonZatrz:SetHeight(20);
  BB_ButtonZatrz:SetText("O");
  BB_ButtonZatrz:ClearAllPoints();
  BB_ButtonZatrz:SetPoint("TOPLEFT", BB_Input1, "TOPRIGHT", -1, 0);
  BB_ButtonZatrz:SetScript("OnClick", BB_TRzatrzask);
  BB_ButtonZatrz:Hide();

end

  
function BB_ExpandUnitInfo(msg)
   msg = string.gsub(msg, "YOUR_CLASS1", player_class.M);          -- Mianownik (kto, co?)
   msg = string.gsub(msg, "YOUR_CLASS2", player_class.B);          -- Biernik (kogo, co?)
   msg = string.gsub(msg, "YOUR_CLASS3", player_class.N);          -- Narzędnik (kim, czym?)
   msg = string.gsub(msg, "YOUR_CLASS4", player_class.W);          -- Wołacz (o!)
   msg = string.gsub(msg, "YOUR_RACE1", player_race.M);            -- Mianownik (kto, co?)
   msg = string.gsub(msg, "YOUR_RACE2", player_race.B);            -- Biernik (kogo, co?)
   msg = string.gsub(msg, "YOUR_RACE3", player_race.N);            -- Narzędnik (kim, czym?)
   msg = string.gsub(msg, "YOUR_RACE4", player_race.W);            -- Wołacz (o!)
   
   msg = string.gsub(msg, "YOUR_RACE YOUR_CLASS", "YOUR_RACE "..player_class.M);     -- Mianownik (kto, co?)
   msg = string.gsub(msg, "ym YOUR_RACE", "ym "..player_race.N);              -- Narzędnik (kim, czym?)
   msg = string.gsub(msg, " jesteś YOUR_RACE", " jesteś "..player_race.N);    -- Narzędnik (kim, czym?)
   msg = string.gsub(msg, "YOUR_RACE", player_race.W);                        -- Wołacz - pozostałe wystąpienia
   
   msg = string.gsub(msg, "ym YOUR_CLASS", "ym "..player_class.N);            -- Narzędnik (kim, czym?)
   msg = string.gsub(msg, "esteś YOUR_CLASS", "esteś "..player_class.N);      -- Narzędnik (kim, czym?)
   msg = string.gsub(msg, " z Ciebie YOUR_CLASS", " z Ciebie "..player_class.M);    -- Mianownik (kto, co?)
   msg = string.gsub(msg, " kolejny YOUR_CLASS do ", " kolejny "..player_class.M.." do ");   -- Mianownik (kto, co?)
   msg = string.gsub(msg, " taki YOUR_CLASS", " taki "..player_class.M);      -- Mianownik (kto, co?)
   msg = string.gsub(msg, "ako YOUR_CLASS", "ako "..player_class.M);          -- Mianownik (kto, co?)
   msg = string.gsub(msg, " co sprowadza YOUR_CLASS", " co sprowadza "..player_class.B);     -- Biernik (kogo, co?)
   msg = string.gsub(msg, " będę miał YOUR_CLASS", " będę miał "..player_class.B);  -- Biernik (kogo, co?)
   msg = string.gsub(msg, "ego YOUR_CLASS", "ego "..player_class.B);                -- Biernik (kogo, co?)
   msg = string.gsub(msg, "YOUR_CLASS taki jak ", player_class.B.." taki jak ");    -- Biernik (kogo, co?)
   msg = string.gsub(msg, " jak na YOUR_CLASS", " jak na "..player_class.B);        -- Biernik (kogo, co?)
   msg = string.gsub(msg, "YOUR_CLASS", player_class.W);                      -- Wołacz - pozostałe wystąpienia

   return msg;
end


function BBTR_onEvent(self, event, name, ...)
   if (event == "ADDON_LOADED") then
      self:UnregisterEvent("ADDON_LOADED");
      ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_PARTY", ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_WHISPER", ChatFilter)
      ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", ChatFilter)
      SlashCmdList["WOWPOPOLSKU_BUBBLES"] = function(msg) BB_SlashCommand(msg); end
      SLASH_WOWPOPOLSKU_BUBBLES1 = "/wowpopolsku-bubbles";
      SLASH_WOWPOPOLSKU_BUBBLES2 = "/bbtr";
      BB_CheckVars();
      BB_BlizzardOptions();
      BB_OknoTRonline();
      DEFAULT_CHAT_FRAME:AddMessage("|cffffff00WoWpoPolsku-Bubbles ver. "..BB_version.." - uruchomiomo");
      BB_name = UnitName("player");
      BB_class= UnitClass("player");
      BB_race = UnitRace("player");
      BB_BubblesArray = {};
      p_race = {
      ["Blood Elf"] = { M = "Krwawy Elf", W = "krwawy elfie", B = "krwawego elfa", N = "krwawym elfem" }, 
      ["Dark Iron Dwarf"] = { M = "Krasnolud Ciemnego Żelaza", W = "krasnoludzie Ciemnego Żelaza", B = "krasnoluda Ciemnego Żelaza", N = "krasnoludem Ciemnego Żelaza" },
      ["Draenei"] = { M = "Draenei", W = "draeneiu", B = "draeneia", N = "draeneiem" },
      ["Dwarf"] = { M = "Krasnolud", W = "krasnoludzie", B = "krasnoluda", N = "krasnoludem" },
      ["Gnome"] = { M = "Gnom", W = "gnomie", B = "gnoma", N = "gnomem" },
      ["Goblin"] = { M = "Goblin", W = "goblinie", B = "goblina", N = "goblinem" },
      ["Highmountain Tauren"] = { M = "Tauren z Wysokiej Góry", W = "taurenie z Wysokiej Góry", B = "taurena z Wysokiej Góry", N = "taurenen z Wysokiej Góry" },
      ["Human"] = { M = "Człowiek", W = "człowieku", B = "człowieka", N = "człowiekiem" },
      ["Kul Tiran Human"] = { M = "Człowiek z Kul Tiran", W = "człowieku z Kul Tiran", B = "człowieka z Kul Tiran", N = "człowiekiem z Kul Tiran" },
      ["Lightforged Draenei"] = { M = "Świetlisty Draenei", W = "świetlisty draeneiu", B = "świetlistego draeneia", N = "świetlistym draeneiem" },
      ["Mag'har Orc"] = { M = "Ork z Mag'har", W = "orku z Mag'ha", B = "orka z Mag'ha", N = "orkiem z Mag'ha" },
      ["Nightborne"] = { M = "Dziecię Nocy", W = "Dziecię Nocy", B = "Dziecię Nocy", N = "Dzieciem Nocy" },
      ["Night Elf"] = { M = "Nocny Elf", W = "nocny elfie", B = "nocnego elfa", N = "nocnym elfem" },
      ["Orc"] = { M = "Ork", W = "orku", B = "orka", N = "orkiem" },
      ["Pandaren"] = { M = "Pandaren", W = "pandarenie", B = "pandarena", N = "pandarenem" },
      ["Tauren"] = { M = "Tauren", W = "taurenie", B = "taurena", N = "taurenem" },
      ["Troll"] = { M = "Troll", W = "trollu", B = "trolla", N = "trollem" },
      ["Undead"] = { M = "Nieumarły", W = "nieumarły", B = "nieumarłego", N = "nieumarłym" },
      ["Void Elf"] = { M = "Elf Pustki", W = "elfie Pustki", B = "elfa Pustki", N = "elfem Pustki" },
      ["Worgen"] = { M = "Worgen", W = "worgenie", B = "worgena", N = "worgenem" },
      ["Zandalari Troll"] = { M = "Troll z Zandalari", W = "trollu z Zandalari", B = "trolla z Zandalari", N = "trollem z Zandalari" }, }
      p_class = {
      ["Death Knight"] = { M = "Rycerz Śmierci", W = "rycerzu śmierci", B = "rycerza śmierci", N = "rycerzem śmierci" },
      ["Demon Hunter"] = { M = "Łowca demonów", W = "łowco demonów", B = "łowcę demonów", N = "łowcą demonów" },
      ["Druid"] = { M = "Driud", W = "druidzie", B = "druida", N = "druidem" },
      ["Hunter"] = { M = "Łowca", W = "łowco", B = "łowcę", N = "łowcą" },
      ["Mage"] = { M = "Czarodziej", W = "czarodzieju", B = "czarodzieja", N = "czarodziejem" },
      ["Monk"] = { M = "Mnich", W = "mnichu", B = "mnicha", N = "mnichem" },
      ["Paladin"] = { M = "Paladyn", W = "paladynie", B = "paladyna", N = "paladynem" },
      ["Priest"] = { M = "Kapłan", W = "kapłanie", B = "kapłana", N = "kapłanem" },
      ["Rogue"] = { M = "Łotrzyk", W = "łotrzyku", B = "łotrzyka", N = "łotrzykiem" },
      ["Shaman"] = { M = "Szaman", W = "szamanie", B = "szamana", N = "szamanem" },
      ["Warlock"] = { M = "Czarnoksiężnik", W = "czarnoksiężniku", B = "czarnoksiężnika", N = "czarnoksiężnikiem" },
      ["Warrior"] = { M = "Wojownik", W = "wojowniku", B = "wojownika", N = "wojownikiem" }, }
      if (p_race[BB_race]) then      
         player_race = { M = p_race[BB_race].M, W = p_race[BB_race].W, B = p_race[BB_race].B, N = p_race[BB_race].N };
      else   
         player_race = { M = BB_race, W = BB_race, B = BB_race, N = BB_race };
         print ("|cff55ff00BB - nowa rasa: "..BB_race);
      end
      if (p_class[BB_class]) then
         player_class = { M = p_class[BB_class].M, W = p_class[BB_class].W, B = p_class[BB_class].B, N = p_class[BB_class].N };
      else
         player_class = { M = BB_class, W = BB_class, B = BB_class, N = BB_class };
         print ("|cff55ff00BB - nowa klasa: "..BB_class);
      end
   end
end


local BBTR_f = CreateFrame("Frame");
BBTR_f:RegisterEvent("ADDON_LOADED");
BBTR_f:SetScript("OnEvent", BBTR_onEvent);
