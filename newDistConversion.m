maptable2014 = maptable;

maptable2014(maptable2014.iso == 608,:)=[];
maptable2014(maptable2014.iso == 609,:) = [];
murtal = {'Murtal', 620, maptable.value(maptable.iso == 609)+maptable.value(maptable.iso == 608)};
maptable2014 = [maptable2014;murtal];

maptable2014(maptable2014.iso == 613,:)=[];
maptable2014(maptable2014.iso == 602,:)=[];
BruckMurzzuschlag = {'Bruck-Mürzzuschlag', 621, maptable.value(maptable.iso == 602)+maptable.value(maptable.iso == 613)};
maptable2014 = [maptable2014;BruckMurzzuschlag];

maptable2014(maptable2014.iso == 607,:)=[];
maptable2014(maptable2014.iso == 605,:)=[];
HartberFurstenfeld = {'Hartberg-Fürstenfeld', 622, maptable.value(maptable.iso == 605)+maptable.value(maptable.iso == 607)};
maptable2014 = [maptable2014;HartberFurstenfeld];

maptable2014(maptable2014.iso == 615,:)=[];
maptable2014(maptable2014.iso == 604,:)=[];
Sudoststeiermark = {'Südoststeiermark', 623, maptable.value(maptable.iso == 604)+maptable.value(maptable.iso == 615)};
maptable2014 = [maptable2014;Sudoststeiermark];

load('doc_db.mat')
for i = 1:23
pats(i) = sum(doctor_db.mean_patients(doctor_db.distnum == i));
end
WienDist = [901,902,903,904,905,906,907, 908, 909, 910, 911, 912, 913, 914, 915, 916, 917, 918,919, 920, 921, 922, 923];

value = sum(maptable.value(ismember(maptable.iso, WienDist)).*pats')/sum(pats);
Wien = {'Wien', 900, value};
maptable2014 = [maptable2014; Wien];
maptable2014(ismember(maptable2014.iso, WienDist),:)=[];

maptable2014.value(isnan(maptable2014.value))=0;