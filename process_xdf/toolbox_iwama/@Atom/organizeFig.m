function str = organizeFig(num,str)

if nargin < 1
    num = input('How many kinds of figures are there?->');
end

if nargin < 2
    str = sprintf('Dir_Figures_%s',Atom.datenow);
end

for i = 1 : num
    Atom.movefile(sprintf('*%02d.jpg',i),fullfile(cd,sprintf('fig%02d',i)));
    Atom.movefile(sprintf('*%02d.fig',i),fullfile(cd,sprintf('fig%02d',i)));
    Atom.movefile(sprintf('*%02d.pdf',i),fullfile(cd,sprintf('fig%02d',i)));
end

Atom.movefile('fig*',str);
end