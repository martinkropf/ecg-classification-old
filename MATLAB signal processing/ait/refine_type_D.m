function [ isNOtPostmature ] = refine_type_D( isPostmature, classes, BCIs, pars )
% GSc 2017-08-19
% Refine type D events
% types_new is a vector of zeros indicating corrected Ds by 1
isNOtPostmature=zeros(size(isPostmature));
I_D=find(isPostmature & BCIs < 60/40);
I_D=I_D(I_D>2); % at least two preceeding events necessary
for i=1:numel(I_D)
    I2check=I_D(i)-2:I_D(i)-1;
    ints2check=BCIs(I2check);
    %       if any(types(I2check)=='V' | types(I2check)=='A')
%    diff2prev2ints=abs(sum(ints2check)-BCIs(I_D(i)))
    diff2prev2ints_rel=sum(ints2check)/BCIs(I_D(i));
    if diff2prev2ints_rel < 1.1 && any(classes(I2check)~=classes(I_D(i)))
        isNOtPostmature(I_D(i))=1;
    end
    %       end
    I2check=I_D(i)-1:I_D(i);
    ints2check=BCIs(I2check);
    %       if any(types(I2check)=='V' | types(I2check)=='A')
%    diff2prev2ints=abs(sum(ints2check)-BCIs(I_D(i)-2))
    diff2prev2ints_rel=sum(ints2check)/BCIs(I_D(i)-2);
    if diff2prev2ints_rel < 1.1
        isNOtPostmature(I_D(i))=1;
    end
    %       end
end


