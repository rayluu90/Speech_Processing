 function rstar = sgtsmooth(r, Nr)
   % rstar= sgtsmooth(r, Nr)
   % Given a vector of frequencies r, and corresponding counts
   % of how many times things of that frequency occur Nr, compute
   % smoothed counts using the simple Good?Turing (SGT) estimator.
   %
   % The function returns Gale's SGT estimates as:
   % rstar, where rstar(k) is the SGT estimate of r(k) for all indices
   %    1 <= k <= length(r).
   %
   % Implementation follows the methods described in:
   %
   % Gale, W. (1994). "Good?Turing Smoothing Without Tears,"
   % J. Quant. Linguistics 2, 24.
   
   % compute the Zr
   Zr = compute_Zr( r,Nr );
   
   % find the polynomial function to fit with the data
   p = polyfit( log(r),log(Zr),1 );
   % get the value of the polynomial function
   y = polyval(p,log(r));

   % get the slope
   b = p(1);
   
   % set the number of Turing r need to compute
   num_r = 30;
   
   % compute Turing rstar based on the number of num_r
   rstar_Turing = compute_rstar_Turing(r, Nr, num_r);
   
   % compute SGT rstar based on the r and b (slope)
   rstar_SGT = r .* ( 1 + (1 ./ r) ) .^ ( b + 1 );
   
   % compute the Turing variances based on the number num_r
   vars_Turing = compute_Turing_var( r, Nr, num_r );
   
   % set up the threshold for each Turing variances
   threshold = 1.65 .* sqrt( vars_Turing );
   
   % compute the difference of rstar_Turing and rstar_SGT from 1 : num_r
   rstar_diff = abs( rstar_Turing - rstar_SGT(1 : num_r) );
   
   row_num = size( r,1 );
   rstar = zeros( row_num,1 );
   
   % for each r value
   for row = 1 : row_num
       % if the current r position < num_r
       if( row <= num_r )
           % if the the difference of rstar_Turing and rstar_SGT > threshold
           if ( rstar_diff( row ) >= threshold( row ) )
               % the Turing_rstar will be used
               rstar( row ) = rstar_Turing( row );
               % skip to the next iteration
               continue;
           end
       end
       % if the the difference of rstar_Turing and rstar_SGT < threshold
       % or
       % if the current r position > num_r
       % use rstar_SGT
       rstar( row ) = rstar_SGT( row );
   end
   
   figure('Name','r vs Nr');
   plot(log(r),log(Nr),'o');

   title('r vs. Nr');
   xlabel 'log(r)';
   ylabel 'log(Nr)';
   
   
   figure('Name','r vs. Zr');
   plot( log(r),log(Zr),'o');
   title('r vs. Zr');

   xlabel 'log(r)';
   ylabel 'log(Zr)';
   hold on;
   
   plot(log(r),y,'r');

   hold off;
   
   legend('SGT','Linear Fit');   
   
%    ratio = rstar_Turing(1:num_r) ./ r(1:num_r);
%    ratio = rstar_SGT(1:num_r) ./ r(1:num_r);
%    ratio = rstar ./ r;
   
   ratio = rstar_SGT ./ r;

   figure('Name','r vs. SGT-r*/r');
%    plot( r(1:num_r), ratio ,'.' );
   plot( r, ratio ,'.' );
   title('r vs. SGT-r*/r ');
   xlabel 'r';
   ylabel 'Ratio (SGT-r*/r)';

   
   
   
 end
 
 function Turing_vars = compute_Turing_var( r,Nr,num_r )
 % Turing_vars = compute_Turing_var( r,Nr )
 % compute the variance of Turing's r from given r and Nr
 
    Turing_vars = zeros( num_r,1 );

    % for each r
    for row = 1 : num_r
        % get the r value 
        r_ = r( row );
        % get Nr value
        Nr_ = Nr( row );
        % get N(r+1) value
        N_rplusone = Nr( row + 1 );
        
        % compute Turing variances for each r
        Turing_vars( row ) = ...
            ( r_ + 1 ) ^ 2 * ( ( N_rplusone ) / (Nr_) ^ 2 ) * ( 1 + ( N_rplusone / Nr_ ) );
    end
 end
 
 function Zr = compute_Zr( r,Nr )
% Zr = compute_Zr(r, Nr)
% Given r and Nr
% compute Zr using Nr and r
% Zr = Nr / ( 0.5 * ( t - q ) )
    
    % get number of rows
    row_num = size( r,1 );
    % preallocate Zr
    Zr = zeros(row_num,1);
 
    % for each row except the first and the last row
    % compute the Zr
    for current = 1 : row_num
        % if the row is the first or the last
        if( current == 1 || current == row_num)
            % set the value of Zr to Nr
            Zr( current ) = Nr( current );
            continue;
        end
        % get current Nr
        Nr_ = Nr( current );
        % get last r
        q = r( current - 1 );
        % get r after
        t = r( current + 1 );
        
        % compute z
        Zr( current ) = Nr_ / ( 0.5 * ( t - q ) );
    end
 end

 function rstar_Turing = compute_rstar_Turing( r, Nr , num_r )
 % rstar_Turing = compute_rstar_Turing( r, Nr , num_r )
 % compute the Turing rstar based on the given set of r (num_r)
    
    
    rstar_Turing = zeros( num_r, 1 );
    
    % for each r
    for row = 1 : num_r
        % get the value of r
        r_ = r( row );
        
        % get value of Nr
        Nr_ = Nr( row );
        
        % get the value of N(r+1)
        N_rplusone = Nr( row + 1 );
        
        % compute the Turing rstar
        rstar_ = ( r_ + 1 ) .* ( N_rplusone / Nr_ );
        
        rstar_Turing( row ) = rstar_;
    end
end
 
 
 