% Destroying networks
t = [];
for N = 10:10:200
    tic;
    p = 0.2;
    A = rand(N)<p;
    B = randi(N, N);
    B(~A)=0;
    A = B;
    A = A - diag(diag(A));
    res = struct();
    for ij = 1:1000
        res(ij).seq = destroy(A);
    end
    t(end+1) = toc;
end
plot(10:10:200,t)