function Int = theorsphere(q,R)

% Int = theorsphere(q,R)
%
% Note: Not multiplied with volume^2.
%
% Created: UV 2003


Int = zeros(size(q));

Int = 9*((sin(q*R) - q*R.*cos(q*R)).^2)./((q*R).^6);

