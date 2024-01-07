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

% Génération du signal OFDM -> replace l'info sur 1 vecteur ligne
signal_OFDM = reshape(symboles_OFDM, 1, n);  


% =================================================================
% =                                                               =
% = 3 Implantation de la chaine de transmission OFDM avec         =
% =   canal multi-trajets, sans bruit                             =
% =                                                               =    
% = 3.1 Implantation sans intervalle de garde                     =
% =                                                               =
% =================================================================



% INITIALISATION DU CANAL MULTI-TRAJET
h = [0.227 0.46 0.688 0.46 0.227];

% Tracer de la réponse en fréquence du canal de propagation
figure;
subplot(2,1,1)
plot(abs(fft(h)))
title("Module de la réponse en fréquence du canal de propagation")
subplot(2,1,2)
plot(angle(fft(h)) )
title("Phase de la réponse en fréquence du canal de propagation")



% Réception du signal après canal multitrajet
% Passage du signal OFDM dans le canal de propagation multitrajets
signal_recu = filter(h,1,signal_OFDM);


% Visualisation des DSP du signal en entrée / sortie du canal
[DSP_entree_canal, f_entree_canal] = pwelch(signal_OFDM, [],[],[], Fe, "twosided");
[DSP_sortie_canal, f_sortie_canal] = pwelch(signal_recu, [],[],[], Fe, "twosided");

% Tracé des 2 DSP
%
% DSP 2 graphes séparés
figure;
subplot(2,1,1);
plot(f_entree_canal, 10*log10(DSP_entree_canal));
title('DSP du signal en entrée du canal');
xlabel('Fréquence (Hz)');
ylabel('Densité Spectrale de Puissance (dB)');
grid on;

subplot(2,1,2);
plot(f_sortie_canal, 10*log10(DSP_sortie_canal));
title('DSP du signal en sortie du canal');
xlabel('Fréquence (Hz)');
ylabel('Densité Spectrale de Puissance (dB)');
grid on;

% DSP même graphe
figure;
plot(f_entree_canal, 10*log10(DSP_entree_canal), 'b', 'LineWidth', 1.5);
hold on;
plot(f_sortie_canal, 10*log10(DSP_sortie_canal), 'r', 'LineWidth', 1.5);
hold off;
title('DSP du signal en entrée et en sortie du canal');
xlabel('Fréquence (Hz)');
ylabel('Densité Spectrale de Puissance (dB)');
legend('Entrée du canal', 'Sortie du canal');
grid on;



% Opération chaine de réception 
% Reshape pour obtenir l'information de chaque porteuses
mat_recu = reshape(signal_recu, N, n/N);

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

