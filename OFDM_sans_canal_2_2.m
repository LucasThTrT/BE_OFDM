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



% 2.2 Réception sans canal

% Génération des bits / de l'information
bits = randi([0 1],1,n);

% Création des symboles
symboles = 2*bits - 1;  % Mapping BPSK | 1 --> +1V | 0 --> -1V |

% Division de l'information en N Monoporteuse
symboles_OFDM = reshape(symboles, N, n/N);  % N lignes = N monoporteuses 


% on passe en mode temporel avec ifft pour générer le signal OFDM
Mat_signal_OFDM = ifft(symboles_OFDM);


% on reforme le signal à transmettre / reçu
signal_OFDM = reshape(Mat_signal_OFDM,1,n);


% Réception
% on le passe dans le domaine fréquentielle pour la décision
Mat_recu = fft(reshape(signal_OFDM, N, n/N));

% on construit le signal a traiter
signal_traitement = reshape(Mat_recu, 1, n);



% Décision

% Calcul du TEB Théorique
% Prend la décision de bits = 1 ssi val_reel > 0 
% sinon = 0 !
% Ce qui correspond bien a notremodulation d'origine
mat_decision = real(signal_traitement) > 0;

mat_erreur = (mat_decision ~= bits); % si différent -> 1

TEB = sum(mat_erreur)/n;
disp("TEB théorique = " + TEB);


