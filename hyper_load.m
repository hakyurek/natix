% -------------------------------------------------------------------------
% License GPL v3.0
% Author: Borja Ayerdi <borja.ayerdi@ehu.es>
% Computational Intelligence Group <www.ehu.es/ccwintco>
% University Of The Basque Country (UPV/EHU)
% Use this at your own risk!
% -------------------------------------------------------------------------

function [X Y fil col depth] = hyper_load(DB)

switch DB
    case 1
        % SALINAS C
        load ~/data/salinasC.mat
        fil=217;
        col=512;
        Y=Y-1;
        depth = 224;
    case 2
        % SALINAS A
        load ~/data/salinasA.mat
        fil=86;
        col=83;
        Y=Y-1;
        depth = 224;
    case 3
        % PAVIA UNIV
        load ~/data/PaviaU.mat;
        fil=610;
        col=340;
        X=reshape(paviaU,fil*col,103);
        load ~/data/PaviaU_gt.mat;
        Y=double(reshape(paviaU_gt,fil*col,1));
        depth = 103;
    case 4
        % INDIAN PINES
        load ~/data/Indian_pines_corrected.mat;
        fil=145;
        col=145;
        X=reshape(indian_pines_corrected,fil*col,200);
        load ~/data/Indian_pines_gt.mat;
        Y=double(reshape(indian_pines_gt,fil*col,1));
        depth = 103;
    case 5
        % BOTSWANA
        load ~/data/Botswana.mat;
        fil=1476;
        col=256;
        X=reshape(Botswana,fil*col,145);
        load ~/data/Botswana_gt.mat;
        Y=double(reshape(Botswana_gt,fil*col,1));
        depth = 145;
        
    case 6
        % KSC
        load ~/data/KSC.mat;
        fil=512;
        col=614;
        X=reshape(KSC,fil*col,176);
        load ~/data/KSC_gt.mat;
        Y=double(reshape(KSC_gt,fil*col,1));
        depth = 176;
    otherwise
        warning('Unexpected database.');
end
