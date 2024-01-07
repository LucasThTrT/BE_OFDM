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
% = 4. Impact d'une erreur de synchronisation horloge             =
% =                                                               =   
% =================================================================


% Surdimensionnement du préfixe cyclique 
% Ainsi on ajoute 4*2 = 8 porteuses en plus de préfixe cyclique
mat_OFDM = [symboles_OFDM(end - 7:end,:); symboles_OFDM];  % Ajout en tête des porteuses !!

% On obtient ainsi le signal OFDM avec l'ajout de l'intervalle de garde
signal_OFDM = reshape(mat_OFDM, 1, []); % On replace le signal en 1 seul vecteur ligne


% Réception du signal après canal multitrajet
% Passage du signal OFDM dans le canal de propagation multitrajets
signal_recu_IG = filter(h,1,signal_OFDM);


% Opération chaine de réception 
% Reshape pour obtenir l'information sous forme de porteuse
mat_recu_IG = reshape(signal_recu_IG, N + 8, []);




%
% CAS 1 : Avance de TAUX > delta - TAUX_MAX
% on va reshape notre matrice beaucoup trop tôt pour simuler une avance
% on va ici absorber TOUS les préfixes cycliques dans le symbole
%

mat_signal_CAS_1 = mat_recu_IG(1:N,:); % On prend 8 préfixes cycliques + 8 monoporteuses
mat_signal_CAS_1_freq = fft(mat_signal_CAS_1);


% Tracé de 2 constellations obtenues en réception
constellation_porteuse_5 = mat_signal_CAS_1_freq(5,:);
constellation_porteuse_12 = mat_signal_CAS_1_freq(12,:);

% On va tracer la 5 et 12 ième
figure;
subplot(2, 1, 1);
plot(real(constellation_porteuse_5), imag(constellation_porteuse_5), 'x');
title('Constellation de la 5ème porteuse (CAS 1)');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;

subplot(2, 1, 2);
plot(real(constellation_porteuse_12), imag(constellation_porteuse_12), 'x');
title('Constellation de la 12ème porteuse (CAS 1)');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;




%
% CAS 2 : Avance de TAUX < delta - TAUX TAUX_MAX
% on va reshape notre matrice beaucoup trop tôt pour simuler une avance
% on va ici absorber UNE PARTIE des préfixes cycliques dans le symbole
%

mat_signal_CAS_2 = mat_recu_IG(4:N + 4,:); % On prend 4 préfixes cycliques + 12 monoporteuses
mat_signal_CAS_2_freq = fft(mat_signal_CAS_2);


% Tracé de 2 constellations obtenues en réception
constellation_porteuse_5 = mat_signal_CAS_2_freq(5,:);
constellation_porteuse_12 = mat_signal_CAS_2_freq(12,:);

% On va tracer la 5 et 12 ième
figure;
subplot(2, 1, 1);
plot(real(constellation_porteuse_5), imag(constellation_porteuse_5), 'x');
title('Constellation de la 5ème porteuse (CAS 2)');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;

subplot(2, 1, 2);
plot(real(constellation_porteuse_12), imag(constellation_porteuse_12), 'x');
title('Constellation de la 12ème porteuse (CAS 2)');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;




%
% CAS 3 : Retard de TAUX
% on va reshape notre matrice trop tard pour simuler le retard
%
% Sélection des 10 monoporteuses de l'instant t
mat_signal_CAS_3_part1 = mat_recu_IG(1:10, :);

% Sélection des 2 premières monoporteuses de l'instant t+1
mat_signal_CAS_3_part2 = mat_recu_IG(N + (1:2), :);

% Concaténation des deux parties
mat_signal_CAS_3 = [mat_signal_CAS_3_part1; mat_signal_CAS_3_part2];

% Calcul de la transformée de Fourier
mat_signal_CAS_3_freq = fft(mat_signal_CAS_3);

% Tracé des constellations
constellation_porteuse_5 = mat_signal_CAS_3_freq(5, :);
constellation_porteuse_12 = mat_signal_CAS_3_freq(12, :);

% Tracer la 5ème porteuse
figure;
subplot(2, 1, 1);
plot(real(constellation_porteuse_5), imag(constellation_porteuse_5), 'x');
title('Constellation de la 5ème porteuse (CAS 3)');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;

% Tracer la 12ème porteuse
subplot(2, 1, 2);
plot(real(constellation_porteuse_12), imag(constellation_porteuse_12), 'x');
title('Constellation de la 12ème porteuse (CAS 3)');
xlabel('Partie réelle');
ylabel('Partie imaginaire');
axis equal;
grid on;

