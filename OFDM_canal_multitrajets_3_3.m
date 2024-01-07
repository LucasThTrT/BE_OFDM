clear all;
close all;

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


% Génération du signal OFDM
% Génération des bits / de l'information
bits = randi([0 1],1,n);

% Création des symboles
symboles = 2*bits - 1;  % Mapping BPSK | 1 --> +1V | 0 --> -1V |

% On reshape pour faire correspondre aux N porteuses
symboles_OFDM = reshape(symboles, N, n/N);

% Passe dans le mode temporel
symboles_OFDM = ifft(symboles_OFDM);


% INITIALISATION DU CANAL MULTI-TRAJET
h = [0.227 0.46 0.688 0.46 0.227];


% =================================================================
% =                                                               =
% = 3 Implantation de la chaine de transmission OFDM avec         =
% =   canal multi-trajets, sans bruit                             =
% =                                                               =    
% = 3.3 Implantation avec préfixe cyclique                        =
% =                                                               =
% =================================================================


% Ajout de préfixe cyclique 4 porteuses en plus
% on ajoute au débuts des monoporteuses la copie des 4 dernières
mat_OFDM = [symboles(end-4:end,:); symboles_OFDM];  % Ajout en tête des porteuses !!

% On obtient ainsi le signal OFDM avec l'ajout de l'intervalle de garde
signal_OFDM = reshape(mat_OFDM, 1, []); % On replace le signal en 1 seul vecteur ligne


% Réception du signal après canal multitrajet
% Passage du signal OFDM dans le canal de propagation multitrajets
signal_recu_IG = filter(h,1,signal_OFDM);


% Opération chaine de réception 
% Reshape pour obtenir l'information sous forme de porteuse
mat_recu_IG = reshape(signal_recu_IG, N + 4, []);

% On enlève les 4 premières "porteuses" qui sont l'ajout de préfixe cyclique
mat_recu = mat_recu_IG(5:end,:);

% On repasse en domaine fréquentiel pour le traitement de OFDM
mat_recu_freq = fft(mat_recu);

% Reforme le signal a traiter
signal_traitement = reshape(mat_recu_freq, 1, n);


% Tracé de 2 constellations obtenues en réception
constellation_porteuse_5 = mat_recu_freq(5,:);
constellation_porteuse_12 = mat_recu_freq(12,:);

% On va tracer la 5 et 12 ième
figure;
subplot(2, 1, 1);
plot(real(constellation_porteuse_5), imag(constellation_porteuse_5), 'x');
title('Constellation de la 5ème porteuse');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;

subplot(2, 1, 2);
plot(real(constellation_porteuse_12), imag(constellation_porteuse_12), 'x');
title('Constellation de la 12ème porteuse');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;


% Calcul du TEB Théorique
% Prend la décision de bits = 1 ssi val_reel > 0 
% sinon = 0 !
% Ce qui correspond bien a notremodulation d'origine
mat_decision = (real(signal_traitement)) > 0;
mat_erreur = (mat_decision ~= bits); % si différent -> 1

TEB = sum(mat_erreur)/n;
disp("TEB théorique = " + TEB);
