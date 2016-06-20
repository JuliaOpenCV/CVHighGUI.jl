module CVHighGUI

export imshow, waitKey, destroyWIndow, destroyAllWindows, namedWindow,
    createTrackbar, getTrackbarPos

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
    ex = Expr(:macrocall, Symbol("@icxx_str"), string("cv::", name, ";"))
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

function createTrackbar(trackbarname::String, winname::String,
    value::Ptr{Cint}, count, onChange::Ptr{Void}=C_NULL,
    userdata::Ptr{Void}=C_NULL)
    icxx"""
    cv::createTrackbar($(pointer(trackbarname)), $(pointer(winname)),
        $value, $count, (void(*)(int,void*))$onChange, $userdata);
    """
end
function createTrackbar(trackbarname::String, winname::String,
    value::Vector{Cint}, count;
    onChange::Ptr{Void}=C_NULL, userdata::Ptr{Void}=C_NULL)
    createTrackbar(trackbarname, winname, pointer(value), count,
        onChange, userdata)
end
function createTrackbar(trackbarname::String, winname::String,
    value::Number, count;
    onChange::Ptr{Void}=C_NULL, userdata::Ptr{Void}=C_NULL)
    v = Cint[value]
    createTrackbar(trackbarname, winname, pointer(v), count,
        onChange, userdata)
end

function getTrackbarPos(trackbarname::String, winname::String)
    icxx"cv::getTrackbarPos($(pointer(trackbarname)), $(pointer(winname)));"
end

function namedWindow(winname::String, flags=WINDOW_AUTOSIZE)
    icxx"cv::namedWindow($(pointer(winname)), $flags);"
end

end # module
