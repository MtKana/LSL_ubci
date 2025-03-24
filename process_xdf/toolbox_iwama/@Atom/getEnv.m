function path =getEnv(id)
if ischar(id)
    eval(sprintf('global %s; path = %s;',id,id));
else
    switch id
        case 0
            global git
            path = git;
        case 1
            global HOMEDIR
            path = HOMEDIR;
        case 2
            global genPGM
            path = genPGM;
        case 3
            global LaCie
            path = LaCie;
        case 4
            global PyMRI
            path = PyMRI;
        case 5
            global LaCie2
            path = LaCie2;
        case 6
            global NAS20
            path = NAS20;
    end
end
end