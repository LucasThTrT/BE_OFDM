clear all;
close all;

% =================================================================
% =                                                               =
% = 2 Implantation de la chaine de transmission OFDM sans canal   =
% =                                                               =
% = Dans un premier on va vérifier la bonne implantation de notre =
% = chaine de transmission en observant les différentes DSP       =
% = suivant le nombre de monoporteuses non nulles.                =
% =                                                               =
% = On valide ensuite notre chaine OFDM par le calcul du TEB = 0! =
% =                                                               =
% =================================================================

% Mapping BPSK (moyenne nulle et variance 1) :
% 1 -->  1V
% 0 --> -1V

% Paramètres :
n = 10000;          % nb de bits à transmettre
Fe = 24000;         % (Hz) Fréquences d'échantillonages

% Paramètres des monoporteuses
Ts = 10;            % durée symbole en monoporteuse
Fs = 1/Ts;          % fréquence symbole en monoporteuse
M = 2;              % modulation

% Paramètres de la chaine de transmission OFDM
N = 16;             % nb porteuses
Ts_OFDM = N*Ts;     % durée symbole OFDM
R_OFMD = 1/Ts_OFDM; % débit sortie OFDM



% 2.1 Emission
% On génère ici le signal OFDM avec un nombre différent de monoporteuses
% utilisées

% Génération des bits / de l'information
bits = randi([0 1],1,n);

% Création des symboles
symboles = 2*bits - 1;  % Mapping BPSK | 1 --> +1V | 0 --> -1V |

% Division de l'information en N Monoporteuse
symboles_OFDM = reshape(symboles, N, n/N);  % N lignes = N monoporteuses 



% 1 seule porteuse utilisée sur 16
%
% On met donc 1 seule porteuse avec de l'information = 1 lignes 
% et les N - 1 autres lignes = 0

% La 5ième monoporteuses est utilisée ici
OFDM_1_porteuse = symboles_OFDM;
OFDM_1_porteuse(1:4,:) = 0;    % 4 premières monoporteuses = 0
OFDM_1_porteuse(6:end,:) = 0;  % 6 à la fin des monoporteuses = 0

% on passe en mode temporel avec ifft pour générer le signal OFDM
signal_OFDM_1_porteuse = ifft(OFDM_1_porteuse);

% on reforme le signal pour le transmettre en vecteur ligne
signal_OFDM_1_porteuse = reshape(signal_OFDM_1_porteuse,1,n);

% Calcul de la DSP
[DSP_1_porteuse, f] = pwelch(signal_OFDM_1_porteuse,[],[],[],Fe,"twosided");

% Affichage de la DSP
figure(1)
plot(f, 10*log10(DSP_1_porteuse)); % On met la DSP en dB
title("DSP de la chaine OFDM avec 1 monoporteuse utilisé (5ième)");
xlabel("Fréquence en Hertz")
ylabel("DSP en dB");
grid on;


% 2 porteuses utilisées sur 16
%
% On met donc 2 porteuses avec de l'information = 2 lignes
% et les N - 2 autres lignes = 0

% Les 5ième et 10ième monoporteuses sont utilisées ici
OFDM_2_porteuses = symboles_OFDM;
OFDM_2_porteuses(1:4,:) = 0;    % 4 premières monoporteuses = 0
OFDM_2_porteuses(6:9,:) = 0;    % 6 à 9 monoporteuses = 0
OFDM_2_porteuses(11:end,:) = 0; % 11 à la fin des monoporteuses = 0

% on passe en mode temporel avec ifft pour générer le signal OFDM
signal_OFDM_2_porteuses = ifft(OFDM_2_porteuses);

% on reforme le signal à transmettre / recu
signal_OFDM_2_porteuses = reshape(signal_OFDM_2_porteuses,1,n);

% Calcul de la DSP
[DSP_2_porteuses, f] = pwelch(signal_OFDM_2_porteuses,[],[],[],Fe,"twosided");

% Affichage de la DSP
figure(2)
plot(f, 10*log10(DSP_2_porteuses)); % On met la DSP en dB
title("DSP de la chaine OFDM avec 2 monoporteuses utilisées (5ième et 10ième)");
xlabel("Fréquence en Hertz")
ylabel("DSP en dB");
grid on;


% Les 8 porteuses centrales sont utilisées (4 nulles - 8 utiles - 4 nulles)
%
% On met donc 8 porteuses avec de l'information = 8 lignes
% et les N - 8 autres lignes = 0

% Les 8 monoporteuses centrales sont utilisées ici
OFDM_8_porteuses = symboles_OFDM;
OFDM_8_porteuses(1:4,:) = 0;    % 4 premières monoporteuses = 0
OFDM_8_porteuses(13:end,:) = 0; % 13 à la fin des monoporteuses = 0

% on passe en mode temporel avec ifft pour générer le signal OFDM
signal_OFDM_8_porteuses = ifft(OFDM_8_porteuses);

% on reforme le signal à transmettre / recu
signal_OFDM_8_porteuses = reshape(signal_OFDM_8_porteuses,1,n);

% Calcul de la DSP
[DSP_8_porteuses, f] = pwelch(signal_OFDM_8_porteuses,[],[],[],Fe,"twosided");

% Affichage de la DSP
figure(3)
plot(f, 10*log10(DSP_8_porteuses)); % On met la DSP en dB
title("DSP de la chaine OFDM avec 8 monoporteuses utilisées (5ième à 12ième)");
xlabel("Fréquence en Hertz")
ylabel("DSP en dB");
grid on;


