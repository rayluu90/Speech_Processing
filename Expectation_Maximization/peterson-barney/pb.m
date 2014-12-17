clear all
close all

%--------------------------------------------------------------------------
% Matlab file to plot Peterson Barney data and show its relation to the IPA
% vowel chart
%
% Ross Snider
% October 15, 2008
%--------------------------------------------------------------------------

%-----------------------------------------------------
% Load Peterson Barney data
%-----------------------------------------------------
fid = fopen('verified_pb.data');
pbv = textscan(fid,'%d%d%d%s%f%f%f%f');
fclose(fid);
%------------------------------------------------------
% Note: the Peterson Barney data has 8 columns
%
% Column 1, Speaker Type
%     speaker type: "1", "2" or "3" (for man, women or child). 
% Column 2, Speaker ID
%     speaker id: a number from 1 to 76. (33 men, 28 women and 15 children)
% Column 3, Vowel Number
%     vowel number : a number from 1 to 10 (each vowel is said twice)
% Column 4, Vowel
%     the vowel name. The following list gives the vowel in a h_d context word together with its representation in this column: (heed, iy), (hid, ih), (head, eh), (had, ae), (hod, aa), (hawed, ao), (hood, uh), (who'd, uw), (hud, ah), (heard, er). 
% Column 5, labelled as F0
%     the fundamental frequency in Hertz. 
% Column 6, 7 and 8, labelled as F1, F2 and F3
%     the frequencies in Hertz of the first three formants. 
% See:
% http://www.fon.hum.uva.nl/praat/manual/Create_formant_table__Peterson___Barney_1952_.html
% for more information regarding the data
%--------------------------------------------------------------------------


N = length(pbv{1}); % number of vowel instances
f1 = pbv{6};  % F1 data
f2 = pbv{7};  % F2 data
f1_max = max(f1);
f2_max = max(f2);

%-------------------------------------
% Vowel list
%-------------------------------------
vowel{1} = 'IY';  letter{1} = 'i';
vowel{2} = 'IH';  letter{2} = 'I';
vowel{3} = 'EH';  letter{3} = 'e';
vowel{4} = 'AE';  letter{4} = 'ae';
vowel{5} = 'AH';  letter{5} = '^';
vowel{6} = 'AA';  letter{6} = 'a';
vowel{7} = 'AO';  letter{7} = 'o';
vowel{8} = 'UH';  letter{8} = 'U';
vowel{9} = 'UW';  letter{9} = 'u';
vowel{10} = 'ER'; letter{10} = '3';
%1	IY	[i]
%2	IH	[I]
%3	EH	[e]
%4	AE	[ae]
%5	AH	[^]
%6	AA	[a]
%7	AO	[o]
%8	UH	[U]
%9	UW	[u]
%10	ER	[3]

%----------------------------------------------------------
% Plot the Vowel data (3 plots, one for each speaker type)
%----------------------------------------------------------
cm = colormap;
for spkr = 1:3  % 1=male, 2=female, 3=child
    
    h=figure(spkr)
    set(h,'position',[177 27 1136 942])
    F1 = 761.02;
    F2 = 1538.81;

    hold on;
    plot( F1,F2,'d','MarkerSize',10);
    
    hold on
    for vindex=1:10  % vowel index
        x = [];  % container for vowel data
        c = cm(mod(vindex*25,64),:);  % pick a color for the vowel
        for k=1:N  % go through data
            if spkr == pbv{1}(k) % check if correct speaker
                if length(strfind(char(pbv{4}(k)),vowel{vindex})) > 0 % check if correct vowel
                    h = text(f1(k),f2(k),letter{vindex}, ...
                        'Interpreter', 'none');
                    set(h,'color',c)
                    x=[x; f1(k) f2(k)]; % save data for vowel as row vectors
                end
            end
        end
        %--------------------------------------------
        % Mixture of Gaussian processing goes here
        %--------------------------------------------
        %[muv,covm,piv]=mog(x,M);  % get MOG model
        %mog_contour(muv,covm,piv,axlim,5,c); % plot MOG model
        drawnow
        %pause
    end
        
        
    if spkr == 1
        h=title('33 Males, 10 vowels, 2 repetitions');
        set(h,'FontSize',14);
    elseif spkr == 2
        h=title('28 Females, 10 vowels, 2 repetitions');
        set(h,'FontSize',14);
    elseif spkr == 3
        h=title('15 Children, 10 vowels, 2 repetitions');
        set(h,'FontSize',14);
    end
    axis([0 1500 0 4000])
    h=xlabel('Formant F1 (Hz)');
    set(h,'FontSize',14);
    h=ylabel('Formant F2 (Hz)');
    set(h,'FontSize',14);
    set(gca,'FontSize',14);

    %eval(['print -depsc PBplot_spkr' num2str(spkr) ])  % print figure
end

dothis = false;
if dothis 
    %----------------------------------------------------------
    % Plot Perterson Barney data on an IPA vowel chart
    %----------------------------------------------------------
    figure(4)
    [A, map, alpha] = imread('IPA_vowel_chart_2005.png');
    A = (A>128)*255;
    %colormap('gray')
    [Ar,Ac]=size(A);
    x_offset = 10;
    y_offset = 10;
    x = 1:Ac;
    y = 1:Ar;
    image(x,y,A); hold on

    cm = colormap;
    cm(1,:) = [0 0 0];   % modify the colormap so we can plot the vowel chart as black&white and then plot the vowel letters in color
    cm(end,:) = [1 1 1];
    colormap(cm);

    % original author optimized the plot for male data and the IPA
    % chart is not scaled appropriately for anything else.  unfortunate...
    spkr = [1];
    for k=1:N
        if ismember(pbv{1}(k), spkr)
            for i=1:10
                if length(strfind(char(pbv{4}(k)),vowel{i})) > 0
                    y = f1(k)/1.3 - 50;
                    x = Ac - f2(k)/2.8 + 150;
                    h=text(x,y,letter{i}, 'Interpreter', 'none');
                    set(h,'color',cm(mod(i*25,64),:))
                end
            end
        end
    end
end





