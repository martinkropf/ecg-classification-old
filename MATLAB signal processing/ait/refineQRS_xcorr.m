function [QRS_new,classes_new]=refineQRS_xcorr(seq,QRS,classes,templates,corrMin)
% Check for subclasses with high correlation to each other
% re-unite classes, if appropriate

[m,n]=size(templates.morph);
xc=xcorr(templates.morph(:,:),'coeff');
[cc_max,I_max]=max(xc);
CC_max=reshape(cc_max,n,n);
I_max=reshape(I_max,n,n);
M=tril(CC_max,-1);
[v,i]=sort(M(:),'descend');
[It,Jt] = ind2sub(n,i);
cHighEnough=find(v>=corrMin);
classes_new=classes;
QRS_new=QRS;
for ii=1:numel(cHighEnough)
    c1=templates.sclass(Jt(ii));
    c1nBeats=templates.count(Jt(ii));
    c2=templates.sclass(It(ii));
    c2nBeats=templates.count(It(ii));
    if c1nBeats >= c2nBeats
        targetClass=c1;
        sourceClass=c2;
    else
        targetClass=c1;
        sourceClass=c2;
    end
    Isource=classes_new==sourceClass;
    Itarget=classes_new==targetClass;
    if sum(Isource)
        classes_new(Isource)=targetClass;
        QRS_new(Isource)=QRS(Isource)-(I_max(It(ii),Jt(ii))-I_max(1,1));
    end
end
end