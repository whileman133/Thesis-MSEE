% plotNonlinEISSensitivity.m

clear; close all; clc;
addpath(fullfile("..","TFS"));
addpath(fullfile("..","UTILITY"));
addpath(fullfile("..","XLSX_CELLDEFS"));
addpath(fullfile("..","MAT_CELLDEFS"));
modelname = 'cellLMO';
load([modelname '.mat']);

ff = logspace(-3,5,100);
socPct = 5;
TdegC = 25;
sensStudy.defaults = lumped;
sensStudy.singl.values.pos.alpha = ...
    [0.2 0.8; 0.4 0.8; 0.6 0.8; 0.8 0.8; 0.8 0.6; 0.8 0.4; 0.8 0.2];
sensStudy.singl.multiplier.pos.k0 = [1/5; 1/2; 2; 5];
sensStudy.singl.multiplier.pos.Dsref = [1/5; 1/2; 2; 5];
sensStudy.singl.values.pos.nF = (0.5:0.1:1).';
sensStudy.singl.values.pos.nDL = (0.5:0.1:1).';
sensStudy.singl.multiplier.pos.sigma = [1/5; 1/2; 2; 5];
sensStudy.singl.multiplier.pos.kappa = [1/5; 1/2; 2; 5];
sensStudy.singl.multiplier.sep.kappa = [1/5; 1/2; 2; 5];
sensStudy.singl.multiplier.DL.kappa = [1/5; 1/2; 2; 5];
sensStudy.singl.multiplier.pos.qe = [0.1; 1/2; 2; 10];
sensStudy.singl.multiplier.sep.qe = [0.1; 1/2; 2; 10];
sensStudy.singl.multiplier.DL.qe = [0.1; 1/2; 2; 10];
sensStudy.singl.values.neg.alpha = (0.2:0.2:0.8).';
sensStudy.singl.multiplier.neg.k0 = [1/5; 1/2; 2; 5];
sensStudy.singl.values.neg.nDL = (0.5:0.1:1).';
sensStudy.singl.multiplier.const.psi = [1/5; 1/2; 2; 5];
sensStudy.singl.multiplier.const.kD = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psikD.const.psi = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psikD.const.kD = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psikDqe.const.psi = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psikDqe.const.kD = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psikDqe.pos.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psikDqe.sep.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psikDqe.DL.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psiqe.const.psi = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psiqe.pos.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psiqe.sep.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.psiqe.DL.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.kDqe.const.kD = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.kDqe.pos.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.kDqe.sep.qe = [1/5; 1/2; 2; 5];
sensStudy.joint.multiplier.kDqe.DL.qe = [1/5; 1/2; 2; 5];
sensData = fastopt.runSensitivityStudy( ...
    sensStudy,@(params)calcZ(params,ff,socPct,TdegC));

% Make plot directory.
plotdir = fullfile( ...
    'plots', ...
    sprintf('%s-SENS-H1-%dpct-%ddegC',modelname,socPct,TdegC));
if ~isfolder(plotdir)
    mkdir(plotdir);
end

for data = sensData.results
    Z = [data.output.Z];
    Zb = sensData.baseline.Z;
    if strcmp(data.basename,'kappa')
        % subtract out Z(inf) to show how curve shape changes
        Z = Z - Z(end,:);
        Zb = Zb - Zb(end);
    end
    figure();
    if strcmp(data.perturbType,'multiplier')
        colororder([0 0 0; spring(size(Z,2))]);
        plot(real(Zb),-imag(Zb),':'); hold on;
        plot(real(Z),-imag(Z));
    else
        colororder(spring(size(Z,2)));
        plot(real(Z),-imag(Z))
    end
    if strcmp(data.basename,'kappa')
        labx = '$(\tilde{Z}_\mathrm{1,1}-\tilde{Z}_\mathrm{1,1}(\infty))''$';
        laby = '$(\tilde{Z}_\mathrm{1,1}-\tilde{Z}_\mathrm{1,1}(\infty))''''$';
    else
        labx = '$\tilde{Z}_\mathrm{1,1}''$';
        laby = '$\tilde{Z}_\mathrm{1,1}''$';
    end
    xlabel([labx ...
        ' [$\mathrm{V}\,\mathrm{A}^{-1}$]'],'Interpreter','latex');
    ylabel([laby ...
        ' [$\mathrm{V}\,\mathrm{A}^{-1}$]'],'Interpreter','latex');
    if strcmp(data.analysisType,'joint')
        % Joint paramname too long to include on one line, use abbrev. title!
        title(['$\tilde{v}_\mathrm{cell,1,1}$ ' ...
            'to ' data.paramname],'Interpreter','latex');
    else
        title(['Sensitivity: $\tilde{Z}_\mathrm{1,1}$ ' ...
            'to ' data.paramname ' (Nyquist)'],'Interpreter','latex');
    end
    if strcmp(data.perturbType,'multiplier')
        labels = [{'Baseline'}, data.valuelabels(:)'];
    else
        labels = data.valuelabels; 
    end
    legend(labels,'Location','best','Interpreter','latex');
    setAxesNyquist;
    thesisFormat([0.2 0.1 0.2 0.1]);
    exportgraphics(gcf,fullfile(plotdir,[data.paramnameEscaped '.png']));
    exportgraphics(gcf,fullfile(plotdir,[data.paramnameEscaped '.eps']));
end

function data = calcZ(params,ff,socPct,TdegC)
    tfdata = tfLMB(1j*2*pi*ff,params, ...
        'socPct',socPct,'TdegC',TdegC,'Calc22',false);
    data.Z = tfdata.h11.tfVcell();
end