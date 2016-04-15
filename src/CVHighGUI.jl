module CVHighGUI

export imshow, waitKey, destroyWIndow, destroyAllWindows

using LibOpenCV
using CVCore
using Cxx

libopencv_highgui = LibOpenCV.find_library_e("libopencv_highgui")
try
    Libdl.dlopen(libopencv_highgui, Libdl.RTLD_GLOBAL)
catch e
    warn("You might need to set DYLD_LIBRARY_PATH to load dependencies proeprty.")
    rethrow(e)
end

cxx"""
#include <opencv2/highgui.hpp>
"""

for name in [
    #Flags for cv::namedWindow
    :WINDOW_NORMAL,
    :WINDOW_AUTOSIZE,
    :WINDOW_OPENGL,
    :WINDOW_FULLSCREEN,
    :WINDOW_FREERATIO,
    :WINDOW_KEEPRATIO,
    ]
    ex = Expr(:macrocall, symbol("@icxx_str"), string("cv::", name, ";"))
    @eval global const $name = $ex
end

imshow(winname::AbstractString, mat::AbstractCvMat) =
    icxx"cv::imshow($(pointer(winname)), $(mat.handle));"
imshow(winname::AbstractString, arr::Array) = imshow(winname, Mat(arr))
imshow(winname::AbstractString, expr::MatExpr) = imshow(winname, Mat(expr))

destroyWindow(winname::AbstractString) =
    icxx"cv::destroyWindow($(pointer(winname)));"
destroyAllWindows() = icxx"cv::destroyAllWindows();"

waitKey(delay) = icxx"cv::waitKey($delay);"
waitKey(;delay::Int=0) = waitKey(delay)

end # module
